-------------------------------------------------------------------------------
-- Title      : Wishbone Stream Sink
-- Project    : 
-------------------------------------------------------------------------------
-- File       : wb_stream_sink.vhd
-- Author     : Vitor Finotti Ferreira  <finotti@finotti-Inspiron-7520>
-- Company    : 
-- Created    : 2015-07-27
-- Last update: 2015-08-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: A simple WB packet streaming sink.
-------------------------------------------------------------------------------
-- Copyright (c) 2015     

-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this program. If not, see
-- <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2015-07-27  1.0      vfinotti        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- use work.genram_pkg.all;
use work.wb_stream_pkg.all;


entity wb_stream_sink is
  generic(
    g_dat_width : natural := 32;
    g_adr_width : natural := 4;
    g_tgd_width : natural := 4;
    g_dat_depth : natural := 1
    );

  port (
    clk_i : in std_logic;
    rst_i : in std_logic;
    ce_i  : in std_logic;

    -- Wishbone Fabric Interface I/O
    snk_i : in  t_wbs_sink_in;
    snk_o : out t_wbs_sink_out;

    -- Decoded & buffered fabric
    adr_o     : out std_logic_vector(g_adr_width-1 downto 0);
    dat_o     : out array_dat;
    tgd_o     : out std_logic_vector(g_tgd_width-1 downto 0);
    dvalid_o  : out std_logic;
    busy_i    : in  std_logic;
    ce_core_i : in  std_logic
    );

end wb_stream_sink;

architecture behavior of wb_stream_sink is

  -- Internal signals
  signal en_rd : std_logic := '0';

  -- Creating other input/output registers
  signal r_snk_ack_o   : std_logic := '0';
  signal r_snk_stall_o : std_logic := '0';

  signal r_adr_o    : std_logic_vector(g_adr_width-1 downto 0);
  signal r_dat_o    : array_dat(g_dat_depth-1 downto 0)(g_dat_width-1 downto 0);
  signal r_tgd_o    : std_logic_vector(g_tgd_width-1 downto 0);
  signal r_dvalid_o : std_logic := '0';

  signal r_mid_adr : std_logic_vector(g_adr_width-1 downto 0);
  signal r_mid_dat : array_dat(g_dat_depth-1 downto 0)(g_dat_width-1 downto 0);
  signal r_mid_tgd : std_logic_vector(g_tgd_width-1 downto 0);

begin

  -- Combinatinal logic
  en_rd <= (snk_i.cyc and snk_i.stb and not (busy_i));

  clock_process : process(clk_i) is
  begin  -- process clock_process

    if rising_edge(clk_i) then
      if rst_i = '1' then
        -- Reset registers;

        r_snk_ack_o   <= '0';
        r_snk_stall_o <= '0';

        r_adr_o <= (others => 'X');
        for i in g_dat_depth-1 downto 0 loop
          r_dat_o(i) <= (others => 'X');
        end loop;  -- i

        r_tgd_o <= (others => 'X');

        r_mid_adr <= (others => 'X');
        for i in g_dat_depth-1 downto 0 loop
          r_mid_dat(i) <= (others => 'X');
        end loop;  -- i
        r_mid_tgd <= (others => 'X');

      -- Writing outputs  
      elsif (ce_i = '1') then
        r_snk_stall_o <= busy_i;
        r_snk_ack_o   <= en_rd;

        if (en_rd = '1') then
          if (r_snk_stall_o = '1') then  -- recovering from "stall"
            r_adr_o <= r_mid_adr;
            for i in g_dat_depth-1 downto 0 loop
              r_dat_o(i) <= r_mid_dat(i);
            end loop;  -- i
            r_tgd_o <= r_mid_tgd;
          else                           -- normal operation
            r_adr_o(g_adr_width-1 downto 0) <= snk_i.adr(g_adr_width-1 downto 0);
            for i in g_dat_depth-1 downto 0 loop
              r_dat_o(i) <= snk_i.dat(i);
            end loop;  -- i
            r_tgd_o(g_tgd_width-1 downto 0) <= snk_i.tgd(g_tgd_width-1 downto 0);
          end if;
        end if;

        -- Storing temporarily inputs
        if (r_snk_stall_o = '0' and busy_i = '1') then
          r_mid_adr(g_adr_width-1 downto 0) <= snk_i.adr(g_adr_width-1 downto 0);
          for i in g_dat_depth-1 downto 0 loop
            r_mid_dat(i) <= snk_i.dat(i);
          end loop;  -- i

          r_mid_tgd(g_tgd_width-1 downto 0) <= snk_i.tgd(g_tgd_width-1 downto 0);
        end if;
      end if;
    end if;
    
  end process clock_process;


  -- purpose: Process that allows sink and core to run with different "ce"
  -- type   : sequential
  -- inputs : (ce_i, ce_core_i), rst_i, ce_core_i, busy_i, en_rd
  -- outputs: r_dvalid_o
  dvalid_logic : process (clk_i, rst_i) is
  begin  -- process dvalid_logic
    if rising_edge(clk_i) then
      if rst_i = '1' then               -- asynchronous reset (active high)
        r_dvalid_o <= '0';
      elsif (ce_i = '1') and (busy_i = '0') then  -- assert valid/invalid data
        r_dvalid_o <= en_rd;
      elsif (ce_core_i = '1') and (busy_i = '0') then  -- consume data
        r_dvalid_o <= '0';
      end if;
    end if;
  end process dvalid_logic;

  -- Connecting outputs
  snk_o.ack   <= r_snk_ack_o;
  snk_o.stall <= r_snk_stall_o;

  adr_o    <= r_adr_o;
  dat_o    <= r_dat_o;
  tgd_o    <= r_tgd_o;
  dvalid_o <= r_dvalid_o;

end behavior;
