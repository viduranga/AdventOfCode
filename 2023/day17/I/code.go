package main

import (
	"container/heap"
	"fmt"
	"math"
	"os"

	"github.com/viduranga/AdventOfCode/2023/util"
)

const (
	LEFT_RIGHT int = 0
	UP_DOWN    int = 1
)

type Entry struct {
	direction int
	r         int
	c         int
}

// An Item is something we manage in a priority queue.
type Item struct {
	entry    *Entry // The value of the item; arbitrary.
	priority int    // The priority of the item in the queue.
	// The index is needed by update and is maintained by the heap.Interface methods.
	index int // The index of the item in the heap.
}

// A PriorityQueue implements heap.Interface and holds Items.
type PriorityQueue []*Item

func (pq PriorityQueue) Len() int { return len(pq) }

func (pq PriorityQueue) Less(i, j int) bool {
	// We want Pop to give us the highest, not lowest, priority so we use greater than here.
	return pq[i].priority < pq[j].priority
}

func (pq PriorityQueue) Swap(i, j int) {
	pq[i], pq[j] = pq[j], pq[i]
	pq[i].index = i
	pq[j].index = j
}

func (pq *PriorityQueue) Push(x any) {
	n := len(*pq)
	item := x.(*Item)
	item.index = n
	*pq = append(*pq, item)
}

func (pq *PriorityQueue) Pop() any {
	old := *pq
	n := len(old)
	item := old[n-1]
	old[n-1] = nil  // avoid memory leak
	item.index = -1 // for safety
	*pq = old[0 : n-1]
	return item
}

// update modifies the priority and value of an Item in the queue.
func (pq *PriorityQueue) update(item *Item, entry *Entry, priority int) {
	item.entry = entry
	item.priority = priority
	heap.Fix(pq, item.index)
}

func dijkstra(graph [][]int, s_r, s_c int) ([][][]int, [][][]*Entry) {
	queue := make(PriorityQueue, 0)

	distance := make([][][]int, len(graph))
	prev := make([][][]*Entry, len(graph))

	for r := 0; r < len(graph); r++ {
		distance[r] = make([][]int, len(graph[0]))
		prev[r] = make([][]*Entry, len(graph[0]))

		for c := 0; c < len(graph[0]); c++ {
			prev[r][c] = make([]*Entry, 2)
			if r != s_r || c != s_c {
				distance[r][c] = []int{math.MaxInt32, math.MaxInt32}
				heap.Push(&queue, &Item{entry: &Entry{r: r, c: c, direction: LEFT_RIGHT}, priority: math.MaxInt32})
				heap.Push(&queue, &Item{entry: &Entry{r: r, c: c, direction: UP_DOWN}, priority: math.MaxInt32})
			} else {
				distance[r][c] = []int{0, 0}
				heap.Push(&queue, &Item{entry: &Entry{r: r, c: c, direction: LEFT_RIGHT}, priority: 0})
				heap.Push(&queue, &Item{entry: &Entry{r: r, c: c, direction: UP_DOWN}, priority: 0})
			}
		}
	}

	// directions := []int{LEFT_RIGHT, UP_DOWN}
	directions_map := []int{UP_DOWN, LEFT_RIGHT}

	i_range := []int{-3, -2, -1, 1, 2, 3}

	for queue.Len() > 0 {
		item := heap.Pop(&queue).(*Item)
		u := (*item).entry

		for _, i := range i_range {
			r, c := 0, 0
			heat := 0
			switch u.direction {
			case LEFT_RIGHT:
				if u.c+i < 0 || u.c+i >= len(graph[0]) {
					continue
				}
				r, c = u.r, u.c+i
				switch i {
				case -3:
					heat = graph[u.r][u.c-3] + graph[u.r][u.c-2] + graph[u.r][u.c-1]
				case -2:
					heat = graph[u.r][u.c-2] + graph[u.r][u.c-1]
				case -1:
					heat = graph[u.r][u.c-1]
				case 1:
					heat = graph[u.r][u.c+1]
				case 2:
					heat = graph[u.r][u.c+2] + graph[u.r][u.c+1]
				case 3:
					heat = graph[u.r][u.c+3] + graph[u.r][u.c+2] + graph[u.r][u.c+1]
				}
			case UP_DOWN:
				if u.r+i < 0 || u.r+i >= len(graph) {
					continue
				}
				r, c = u.r+i, u.c
				switch i {
				case -3:
					heat = graph[u.r-3][u.c] + graph[u.r-2][u.c] + graph[u.r-1][u.c]
				case -2:
					heat = graph[u.r-2][u.c] + graph[u.r-1][u.c]
				case -1:
					heat = graph[u.r-1][u.c]
				case 1:
					heat = graph[u.r+1][u.c]
				case 2:
					heat = graph[u.r+2][u.c] + graph[u.r+1][u.c]
				case 3:
					heat = graph[u.r+3][u.c] + graph[u.r+2][u.c] + graph[u.r+1][u.c]
				}
			}

			alt := distance[u.r][u.c][u.direction] + heat

			v_direction := directions_map[u.direction]

			if alt < distance[r][c][v_direction] {
				distance[r][c][v_direction] = alt
				prev[r][c][v_direction] = u

				heap.Push(&queue, &Item{entry: &Entry{r: r, c: c, direction: v_direction}, priority: alt})
			}

		}

	}

	return distance, prev
}

func findXXX(data []string) (int, error) {
	graph := make([][]int, len(data))
	for i := 0; i < len(data); i++ {
		graph[i] = make([]int, len(data[0]))
		for j := 0; j < len(data[0]); j++ {
			graph[i][j] = int(data[i][j] - '0')
		}
	}

	distance, _ := dijkstra(graph, 0, 0)

	fmt.Println(distance[len(data)-1][len(data[0])-1])

	// p := prev[len(data)-1][len(data[0])-1][1]
	// for p != nil {
	// 	fmt.Println(p.r, p.c, p.direction, p.travel)
	// 	p = prev[p.r][p.c][p.direction]
	// }

	min_dist := util.ArrayMin(distance[len(data)-1][len(data[0])-1])
	return min_dist, nil
}

func main() {
	path := os.Args[1]
	lines, err := util.FileToLines(path)
	if err != nil {
		panic(err)
	}

	number, err := findXXX(lines)
	if err != nil {
		panic(err)
	}

	fmt.Println(number)
}
