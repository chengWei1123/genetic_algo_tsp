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
    max_dist:integer := 40;
    min_dist:integer := 10;
    mutation_rate:integer:=100;
    Task_number : integer;
    Task_Load : integer;
    type gene is array (integer range 1..gene_length) of integer range 1..gene_length;
    type map_row is array (integer range 1..gene_length) of integer;
	--use parent(i)(j) to access parent[i][j]
    type container is array(integer range 1..population_size) of gene;
    parent : container;
    childarray   :container;
	--use map(i)(j) to access map[i][j]
    map : array(integer range 1..gene_length) of map_row;

    fitness : array(integer range 1..population_size) of integer;
    --generate random map
    procedure generate_map is
    begin
        for i in 1..gene_length loop
            for j in i..gene_length loop
                map(i)(j) := (random(g) mod max_dist-min_dist+1)+min_dist;
                map(j)(i) := map(i)(j);
                if i=j then
                    map(i)(j) := 0;
                end if;    
            end loop;
        end loop;
    end generate_map;
    
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

    procedure crossover(c_i:integer) is
        p:integer;
        longest:integer:=1;
        tmp:integer;
        r1:integer;
        r2:integer;
    begin
        p:=selection;
        for i in 1..gene_length-1 loop
            if map(parent(p)(i))(parent(p)(i+1)) > map(parent(p)(longest))(parent(p)(longest+1)) then
                longest:=i;
            end if;
        end loop;
        for i in 1..gene_length loop
            if i + longest <= gene_length then 
                childarray(c_i)(i):=parent(p)(i+longest);
            else
                childarray(c_i)(i):=parent(p)((i+longest)mod gene_length);
            end if;
        end loop;
        if random(g) mod mutation_rate = 1 then
            r1:=random(g) mod gene_length +1;
            r2:=random(g) mod gene_length +1;
            tmp:=childarray(c_i)(r1);
            childarray(c_i)(r1):=childarray(c_i)(r2);
            childarray(c_i)(r2):=tmp;
        end if;
    end crossover;

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
            delay(0.001);
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
            if fit<best then
                best :=fit;
                mutation_rate:=100;
                n:=0;
            else 
                n:=n+1;
            end if;
            if n>end_condition/4 then 
                mutation_rate := 75;
            end if;
            if n>end_condition/2 then 
                mutation_rate := 50;
            end if;
            if n>3*end_condition/4 then 
                mutation_rate := 25;
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
    generate_map;
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
            put(final_result,3);
            put("    Current shortest length : ");
            put(best,3);
            new_line;
            generation:=generation+1;
            exit Find_route when result=1; 
            
            --arrayAtoArrayB(parent,childarray);
            for i in 1..population_size loop
                --childgenerate;
                crossover(i);
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
    new_line;
end tsp;
