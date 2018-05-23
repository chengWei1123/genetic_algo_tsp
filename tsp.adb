with ada.numerics.discrete_random;
with ada.text_io; use ada.text_io;
with ada.integer_text_io; use ada.integer_text_io;
with Ada.Calendar; use Ada.Calendar;


procedure tsp is
    package random_num is new ada.numerics.discrete_random (integer);
    use random_num;
    g : generator;
    --total number of population
    population_size : integer := 1000;
    --length of gene = number of node 
    gene_length : integer := 15;
    Task_number : integer;
    Task_Load : integer;
    type gene is array (integer range 1..gene_length) of integer range 1..gene_length;
    type map_row is array (integer range 1..gene_length) of integer;
	--use parent(i)(j) to access parent[i][j]
    type container is array(integer range 1..population_size) of gene;
    parent : container;
    childarray   :container;
	--use map(i)(j) to access map[i][j]
    map : array(integer range 1..gene_length) of map_row:=
(( 0,  6, 17, 23, 27, 16, 20, 22, 13, 24, 27, 16, 10, 24, 29),
(  6,  0,  3, 13, 12, 13, 28, 10, 19, 26, 22, 20, 28, 13, 21),
( 17,  3,  0,  1, 22, 19, 27, 13, 15, 18, 14, 20, 24, 18, 17),
( 23, 13,  1,  0,  6, 11, 26, 24, 24, 14, 15, 10, 18, 25, 25),
( 27, 12, 22,  6,  0,  9, 17, 28, 18, 25, 14, 23, 15, 19, 13),
( 16, 13, 19, 11,  9,  0,  5, 19, 10, 25, 25, 28, 10, 25, 13),
( 20, 28, 27, 26, 17,  5,  0,  4, 12, 17, 23, 16, 26, 23, 18),
( 22, 10, 13, 24, 28, 19,  4,  0,  5, 26, 28, 14, 10, 28, 21),
( 13, 19, 15, 24, 18, 10, 12,  5,  0,  1, 14, 10, 19, 20, 20),
( 24, 26, 18, 14, 25, 25, 17, 26,  1,  0,  7, 28, 24, 23, 20),
( 27, 22, 14, 15, 14, 25, 23, 28, 14,  7,  0,  8, 23, 10, 19),
( 16, 20, 20, 10, 23, 28, 16, 14, 10, 28,  8,  0,  6, 26, 18),
( 10, 28, 24, 18, 15, 10, 26, 10, 19, 24, 23,  6,  0,  5, 12),
( 24, 13, 18, 25, 19, 25, 23, 28, 20, 23, 10, 26,  5,  0,  5),
( 29, 21, 17, 25, 13, 13, 18, 21, 20, 20, 19, 18, 12,  5,  0));

    fitness : array(integer range 1..population_size) of integer;

	--generate first generation
    procedure generate_first is 
        rand_pos : integer; 
        temp :integer;
        arr : gene;
    begin
        for i in 1..population_size loop
            for j in 1..gene_length loop
                arr(j):=j;
            end loop;
            for j in 1..gene_length loop
                rand_pos := (random(g) mod (gene_length-j+1)) + 1;
                parent(i)(j) := arr(rand_pos);
                temp := arr(gene_length-j+1);
                arr(gene_length-j+1) := arr(rand_pos);
                arr(rand_pos) := temp;
            end loop;
        end loop;
    end generate_first;

    function selection return integer is
        sum : integer := 0;
        rand : integer;
    begin
        for i in 1..population_size loop
            sum:=sum+10000/fitness(i);
        end loop;
        rand := (random(g) mod sum) + 1;
        sum := 0;
        for i in 1..population_size loop
            sum:=sum+10000/fitness(i);
            if sum >= rand then
                return i; 
            end if;
        end loop;
        return (population_size);
    end selection;

    --check if exist same element in array yes:1 no:0
    function checksame(TestArray : gene;TestPosition : integer) return integer is 
        ans : integer := 0;
        begin
            for i in 1 .. gene_length loop
                if i=TestPosition then 
                    put("");
                else
                    if TestArray(i)=TestArray(TestPosition) then
                        ans := 1;
                    end if; 
                end if;
            end loop;
        return ans;
    end checksame;

    --generate the child
    procedure childgenerate  is
        
        P1 : integer;
        P2 : integer;
        start : integer;
        last  : integer;
        swaptmp   : integer;
        exam :integer :=0;
    begin
        P1  := selection;
        P2  := selection;
        start   :=  (Random(g) mod gene_length)+1;
        if gene_length-start = 0 then
            last    :=  start;
        else
            last    :=  (Random(g) mod (gene_length-start))+start;
        end if;

        for i in start .. last loop
            swaptmp := childarray(P1)(i);
            childarray(P1)(i) := childarray(P2)(i);
            childarray(P2)(i) := swaptmp;
        end loop;

        for i in start .. last loop
            exam :=0;
            if checksame(childarray(P1),i)=1 then
               for j in start .. last loop
                    if checksame(childarray(P2),j)=1 and exam =0 then
                                    swaptmp := childarray(P1)(i);
                                    childarray(P1)(i) := childarray(P2)(j);
                                    childarray(P2)(j) := swaptmp;
                                    exam :=1;
                    end if;
                end loop;
            end if;
        end loop;
        ----------------------------- Mutation P1
        
        start := Random(g) mod 100;
        if start = 7 then
            start := (Random(g) mod gene_length)+1;
            last := (Random(g) mod gene_length)+1;
            swaptmp := childarray(P1)(start);
            childarray(P1)(start) := childarray(P1)(last);
            childarray(P1)(last) := swaptmp;
        end if;
       

    end childgenerate;

    procedure arrayAtoArrayB(A : in container;B : out container)  is
    begin
        for i in 1 .. population_size loop
            for j in 1 .. gene_length loop
                B(i)(j) :=A(i)(j);
            end loop;
        end loop;
    end arrayAtoArrayB;

    t_start:time;
    t_end:time;
    t_exe:duration;
    package Duration_IO is new Fixed_IO(Duration);



    -------------------------------------------------------------- 

	
	task type T is
		entry Compute_Fitness(i : integer);
	end T;
	
	--type Task_Arr is array (1..Task_number) of T;

	task body T is
        routine : integer;
        loop_number : integer;
        current_i : integer;
	begin
		
		accept Compute_Fitness(i : integer) do
            current_i := i-1;
        end Compute_Fitness;
        loop_number := (Task_Load*(current_i))+1;
		for k in loop_number..(loop_number+Task_Load-1) loop
        	routine := 0;
			for j in 1..(gene_length-1) loop
				routine := routine + map(parent(k)(j))(parent(k)(j+1));
			end loop;
		    fitness(k) := routine;
            delay(0.00001);
        end loop;
        
	end T;
    
    final_result :integer :=0;
    n : integer :=0;
    fit : integer :=1;
    tmp :integer :=0;
    result :integer :=0;
    taskComplete : integer := 0;
    best :integer:=5000;
    end_condition:integer;
	---------------------------

    function condition return integer is
        answer :integer :=0;
        begin
            for i in 1..(population_size-1) loop
                fit := fitness(i);
                if fitness(i+1)<=fitness(i) then
                    fit := fitness(i+1);
                end if;
            end loop;
            if fit<=best then
                best :=fit;
                n:=0;
            else 
                n:=n+1;
            end if;

            if n>end_condition then
                answer:=1;
            else 
                answer:=0;
            end if;
            return answer;
    end condition;
    --------------------------- 
    generation:integer:=1;
begin
    put("End condition : ");
    get(end_condition);
    put("Number of threads : ");
    get(Task_number);
    Task_Load:= population_size/Task_number;
    t_start:=clock;
    reset(g);
    generate_first;
    ----------------------------- start find the route
    Find_route:
    loop
            declare
                Mul_Task : array(1..Task_number) of T;            
            begin
            --------------------------------
            for i in 1..Task_number loop
                Mul_Task(i).Compute_Fitness(i);
            end loop;

            loop
                taskComplete:=0;
                for i in 1..Task_number loop
                    if Mul_Task(i)'Terminated then
                        taskComplete:=taskComplete+1;
                    end if;
                end loop;
                if taskComplete = Task_number then   
                    exit;
                end if;
            end loop;

            result:=condition;
            final_result := fit;
            put(generation,5);
            put(" th generation shortest length : "); 
            put(final_result,0);
            put("    Current shortest length : ");
            put(best,0);
            new_line;
            generation:=generation+1;
            exit Find_route when result=1; 
            
            arrayAtoArrayB(parent,childarray);
            for i in 1..population_size loop
                childgenerate;
            end loop;
            arrayAtoArrayB(childarray,parent);
            
            ------------------------------------------
            end;
    end loop Find_route;
    new_line;
	----------------------------
    
    t_end:=clock;
    t_exe:=t_end-t_start;
    t_exe:=t_exe/(generation-1);
    put("Average execute time for one generation: ");
    Duration_IO.Put(t_exe, 0, 5);
    put_line(" sec");
end tsp;
