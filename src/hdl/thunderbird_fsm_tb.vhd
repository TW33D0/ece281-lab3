--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner, C3C Ty Hubert
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port(
         i_clk, i_reset  : in std_logic;
         i_left, i_right : in std_logic;
         o_lights_L      : out   std_logic_vector(2 downto 0);
         o_lights_R      : out   std_logic_vector(2 downto 0)
	  );
	end component thunderbird_fsm;

	-- test I/O signals
	--Inputs
	signal w_clk : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_right : std_logic := '0';
	signal w_left : std_logic := '0';
	--Outputs
	signal w_lights_L : std_logic_vector(2 downto 0) := "000";
	signal w_lights_R : std_logic_vector(2 downto 0) := "000";
	
	-- constants
	constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
	-- Instantiate the Unit Under Test (UUT)
	uut: thunderbird_fsm port map (
	   i_clk => w_clk,
	   i_reset => w_reset,
	   i_left => w_left,
	   i_right => w_right,
	   o_lights_L => w_lights_L,
	   o_lights_R => w_lights_R
	   );
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
    begin
        w_clk <= '0';
        wait for k_clk_period/2;
        w_clk <= '1';
        wait for k_clk_period/2;
    end process;
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	
	-- Use 220 ns for simulation
	sim_proc: process
	begin
	   -- sequential timing
	   w_reset <= '1';
	   wait for k_clk_period;
	       assert w_lights_L = "000" report "bad reset" severity failure;
	       assert w_lights_R = "000" report "bad reset" severity failure;
       
       w_reset <= '0';
       wait for k_clk_period;
       
       -- no blinker
       w_left <= '0';
       w_right <= '0'; wait for k_clk_period;
        assert w_lights_L = "000" report "should have lights off if no blinker" severity failure;
        assert w_lights_R = "000" report "should have lights off if no blinker" severity failure;
           
       -- right blinker
       --- initial blinker
       w_left <= '0';
       w_right <= '1'; wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off if no left blinker" severity failure;
        assert w_lights_R = "001" report "should have only right light on if right blinker pressed" severity failure;          
       wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off if no left blinker" severity failure;
        assert w_lights_R = "011" report "should have two right lights on after first state" severity failure;          
       wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off if no left blinker" severity failure;
        assert w_lights_R = "111" report "should have all right lights on for last state" severity failure;          
      --- completion of first rotation
       wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off if no left blinker" severity failure;
        assert w_lights_R = "000" report "should have right lights off after rotation" severity failure;          
      --- start of next rotation
       wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off if no left blinker" severity failure;
        assert w_lights_R = "001" report "should restart blinker progress" severity failure;          
       --- turn blinker off
       w_right <= '0';
       wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off if no left blinker" severity failure;
        assert w_lights_R = "011" report "should have two right light on after first state" severity failure;          
       wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off if no left blinker" severity failure;
        assert w_lights_R = "111" report "should have all right lights on for last state" severity failure;          
        --- completion of second rotation         
       wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off if no left blinker" severity failure;
        assert w_lights_R = "000" report "should have right lights off after rotation" severity failure;          
       wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off if no left blinker" severity failure;
        assert w_lights_R = "000" report "should have right lights off if no right blinker" severity failure;          
                          
       -- left blinker
       --- initial blinker
       w_left <= '1';
       w_right <= '0'; wait for k_clk_period;
        assert w_lights_R = "000" report "should have right lights off if no right blinker" severity failure;
        assert w_lights_L = "001" report "should have only left light on if left blinker blinker" severity failure;          
       wait for k_clk_period;
        assert w_lights_R = "000" report "should have right lights off if no right blinker" severity failure;
        assert w_lights_L = "011" report "should have two left light on after first state" severity failure;          
       wait for k_clk_period;
        assert w_lights_R = "000" report "should have right lights off if no right blinker" severity failure;
        assert w_lights_L = "111" report "should have all left lights on for last state" severity failure;          
       --- completion of first rotation
       wait for k_clk_period;
        assert w_lights_R = "000" report "should have right lights off if no right blinker" severity failure;
        assert w_lights_L = "000" report "should have left lights off after rotation" severity failure;          
       --- start of next rotation
       wait for k_clk_period;
        assert w_lights_R = "000" report "should have right lights off if no right blinker" severity failure;
        assert w_lights_L = "001" report "should restart blinker progress" severity failure;          
       --- turn blinker off
       w_left <= '0';
       wait for k_clk_period;
        assert w_lights_R = "000" report "should have right lights off if no right blinker" severity failure;
        assert w_lights_L = "011" report "should have two left light on after first state" severity failure;          
       wait for k_clk_period;
        assert w_lights_R = "000" report "should have right lights off if no right blinker" severity failure;
        assert w_lights_L = "111" report "should have all left lights on for last state" severity failure;          
        --- completion of second rotation         
       wait for k_clk_period;
        assert w_lights_R = "000" report "should have right lights off if no right blinker" severity failure;
        assert w_lights_L = "000" report "should have left lights off after rotation" severity failure;          
       wait for k_clk_period;
        assert w_lights_R = "000" report "should have right lights off if no right blinker" severity failure;
        assert w_lights_L = "000" report "should have left lights off after rotation" severity failure;          
       
       -- both blinker
       w_left <= '1';
       w_right <= '1'; wait for k_clk_period;
        assert w_lights_L = "111" report "should have all on if both blinkers clicked" severity failure;
        assert w_lights_R = "111" report "should have all on if both blinkers clicked" severity failure;          
       wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off after all on" severity failure;
        assert w_lights_R = "000" report "should have right lights off if after all on" severity failure;          
       wait for k_clk_period;
        assert w_lights_L = "111" report "should have all on if both blinkers clicked" severity failure;
        assert w_lights_R = "111" report "should have all on if both blinkers clicked" severity failure;          
       w_left <= '0';
       w_right <= '0'; wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off after all on" severity failure;
        assert w_lights_R = "000" report "should have right lights off after all on" severity failure;          
       wait for k_clk_period;
        assert w_lights_L = "000" report "should have left lights off if no blinker selected" severity failure;
        assert w_lights_R = "000" report "should have right lights off if no blinker selected" severity failure;          
       
       wait;                                       
	end process;
	-----------------------------------------------------	
	
end test_bench;
