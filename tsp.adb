with ada.numerics.discrete_random;
with ada.text_io; use ada.text_io;
with ada.integer_text_io; use ada.integer_text_io;
with Ada.Calendar; use Ada.Calendar;

procedure tsp is
    --total number of population
    population_size : integer := 10000;
    --length of gene = number of node 
    gene_length : integer := 20;
    type gene is array (integer range 1..gene_length) of integer range 1..gene_length;
    type map_row is array (integer range 1..gene_length) of integer;
	--use parent(i)(j) to access parent[i][j]
    parent : array(integer range 1..population_size) of gene;
	--use map(i)(j) to access map[i][j]
    map : array(integer range 1..gene_length) of map_row;

	--generate random map
    procedure generate_map is
        subtype distance is integer range 1..20;
        package random_dis is new ada.numerics.discrete_random (distance);
        use random_dis;
        g : generator;
    begin
        reset(g);
        for i in 1..gene_length loop
            for j in i..gene_length loop
                map(i)(j) := random(g);
                map(j)(i) := map(i)(j);
                if i=j then
                    map(i)(j) := 0;
                end if;    
            end loop;
        end loop;
    end generate_map;

	--generate first generation
    procedure generate_first is 
        package random_num is new ada.numerics.discrete_random (integer);
        use random_num;
        g : generator;
        rand_pos : integer; 
        temp :integer;
        arr : gene;
    begin
        reset(g);
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

    t_start:time;
    t_end:time;
    t_exe:duration;
    package Duration_IO is new Fixed_IO(Duration);
begin
    t_start:=clock;
	----------------------------
	
    generate_map;
    generate_first;
	
	----------------------------
    t_end:=clock;
    t_exe:=t_end-t_start;
    Duration_IO.Put(t_exe, 0, 5); --print out execution time
end tsp;