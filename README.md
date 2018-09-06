# Solving Travelling salesman problem

In this project, I tried to use genetic algorithm to solve Travelling salesman problem, additionally
I parallelize the computation of fitness by using "task" in Ada .

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Installing the GNAT compiler on Linux

```sh
apt-get install gnat-4.3
```

### Running the program

Compile and run

```sh
gnatmake tsp.adb
```
```sh
./tsp
```
### User input

input 1 is end condition. (end condition N means the program will end if after N generations without improvement)  
input 2 is number of tasks.


