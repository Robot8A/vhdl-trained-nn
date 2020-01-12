-- File: activationFunct.vhd
-- Author: Héctor Ochoa Ortiz
-- Date: 2020-01-10


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package activationFunct is
--------------------
  component hard_sigmoid is
    port(X        : in  std_logic_vector(31 downto 0);
         clk      : in  std_logic;
         reset    : in  std_logic;
         go       : in  std_logic;
         done     : out std_logic;
         result   : out std_logic_vector(31 downto 0)
         );
  end component;
--------------------
end package activationFunct;

--------------------
--****************--
--------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.FloatPt.all;

entity hard_sigmoid is
  port(X        : in  std_logic_vector(31 downto 0);
       clk      : in  std_logic;
       reset    : in  std_logic;
       go       : in  std_logic;
       done     : out std_logic;
       result   : out std_logic_vector(31 downto 0)
       );
end hard_sigmoid;
-----------------------------------

architecture ARCH of hard_sigmoid is

--****************************--
--* hard_sigmoid(x):         *--
--* if x < -2.5, result is 0 *--
--* if x >  2.5, result is 1 *--
--* else, result is 0.2x+0.5 *--
--****************************--

-- STATE MACHINE DECLARATION
  type HD_SM is (START, CHCK0, ADDACK, CHCK1, MUL, ADD, FINISH);
  signal state               : HD_SM;
  attribute INIT             : string;
  attribute INIT of state    : signal is "START";
-----------------------------------
-- AUXILIARY INTERNAL SIGNALS
  signal MA, MB, MR, AA, AB, AR : std_logic_vector(31 downto 0);
  signal Mgo, Mdone, Ago, Adone : std_logic; 
  signal notclk : std_logic; 

begin

   notclk <= not (clk);

   -- Arithmetical units --
   umult: FPP_MULT port map
    (		A			=> MA,
		    B			=> MB,
		    clk		    => notclk,
		    reset		=> reset,
		    go			=> Mgo,
		    done		=> Mdone,
		    overflow	=> open,
		    result	    => MR );
		    
    uadd: FPP_ADD_SUB port map
    (		A			=> AA,
		    B			=> AB,
		    clk		    => notclk,
		    reset		=> reset,
		    go			=> Ago,
		    done		=> Adone,
		    result	    => AR );


  process (state, clk, go, reset) is
  begin
    if (reset = '1') then
      done  <= '0';
      state <= START;
    elsif (rising_edge(clk)) then
      case (state) is
        when START =>
          done    <= '0';
          if (go = '1') then
            if (X = "00000000000000000000000000000000") then
              result <= "00111111000000000000000000000000"; -- 0.5
              done   <= '1';
              state  <= FINISH;
            else
              AA    <= X;
              AB    <= "01000000001000000000000000000000"; -- 2.5
              Ago   <= '1';
              state <= CHCK0;
            end if;
          else
            state <= START;
          end if;
        when CHCK0 =>
          done    <= '0';
          if (go = '1') then
            if (Adone = '1') then
                Ago <= '0';
                if (AR(31) = '1') then
                    result <= "00000000000000000000000000000000"; -- 0.0
                    done   <= '1';
                    state  <= FINISH;
                else
                    state <= ADDACK;
                end if;
            else
                state <= CHCK0;            
            end if;
          else
            state <= START;
          end if;
        when ADDACK =>
          done    <= '0';
          if (go = '1') then
            AA    <= X;
            AB    <= "11000000001000000000000000000000"; -- -2.5
            Ago   <= '1';
            state <= CHCK1;
          else
            state <= START;
          end if;
        when CHCK1 =>
          done    <= '0';
          if (go = '1') then
            if (Adone = '1') then
                Ago <= '0';
                if (AR(31) = '0') then
                    result <= "00111111100000000000000000000000"; -- 1.0
                    done   <= '1';
                    state  <= FINISH;
                else
                    MA    <= X;
                    MB    <= "00111110010011001100110011001101"; -- 0.2
                    Mgo   <= '1';
                    state <= MUL;
                end if;
            else
                state <= CHCK1;            
            end if;
          else
            state <= START;
          end if;
        when MUL =>
          done    <= '0';
          if (go = '1') then
            if (Mdone = '1') then
                Mgo <= '0';
                AA    <= MR;
                AB    <= "00111111000000000000000000000000"; -- 0.5
                Ago   <= '1';
                state <= ADD;
            else
                state <= MUL;            
            end if;
          else
            state <= START;
          end if;
        when ADD =>
          done    <= '0';
          if (go = '1') then
            if (Adone = '1') then
                Ago    <= '0';
                result <= AR;
                done   <= '1';
                state  <= FINISH;
            else
                state <= ADD;            
            end if;
          else
            state <= START;
          end if;
        when FINISH =>
          if (go = '1') then
            done  <= '1';
            state <= FINISH;
          else
            done  <= '0';
            state <= START;
          end if;
      end case;
    end if;
  end process;

end ARCH;
