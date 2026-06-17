library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_timer_de2_115 is
  port (
    CLOCK_50 : in std_logic;
    KEY      : in std_logic_vector (3 downto 0); 
    HEX0     : out std_logic_vector (6 downto 0);
    HEX1     : out std_logic_vector (6 downto 0);
    HEX2     : out std_logic_vector (6 downto 0);
    HEX3     : out std_logic_vector (6 downto 0);
    HEX4     : out std_logic_vector (6 downto 0);    
    HEX5     : out std_logic_vector (6 downto 0)
  );
end entity;

architecture top of top_timer_de2_115 is
  -- COMPONENTES DECLARADOS
  component timer is
    port (
      clk, reset   : in std_logic;
      load         : in std_logic;
      hour_i       : in std_logic_vector(4 downto 0);
      sec_i, min_i : in std_logic_vector(5 downto 0);
      hour         : out std_logic_vector(4 downto 0);      
      sec, min     : out std_logic_vector(5 downto 0)
    );
  end component;

  component bin2bcd is
    generic (N : positive := 16);
    port (
      clk, reset                   : in std_logic;
      binary_in                    : in std_logic_vector(N - 1 downto 0);
      bcd0, bcd1, bcd2, bcd3, bcd4 : out std_logic_vector(3 downto 0)
    );
  end component;
  
  component blink is
    port(
      clk, reset, en : in std_logic;
      blink          : out std_logic
    );
  end component;

  component bcd2ssd is
    port (
      BCD : in std_logic_vector (3 downto 0);
      SSD : out std_logic_vector (6 downto 0)
    );
  end component;

  -- DECLARANDO O RELOGIO FSM COMO COMPONENTE
  component fsm_relogio is
    port (
      clk, reset, adjust, plus, less : in std_logic;
      hour_in                        : in std_logic_vector(4 downto 0);
      min_in, seg_in                 : in std_logic_vector(5 downto 0);
      blink_h, blink_m, blink_s      : out std_logic;
      load                           : out std_logic;
      hour_out                       : out std_logic_vector(4 downto 0);
      min_out, seg_out               : out std_logic_vector(5 downto 0)
    );
  end component;

  -- DECLARANDO O SYNC COMO COMPONENTE
  component sync_keys is
    port(
      clk, reset : in std_logic;
      keys_i     : in std_logic_vector(2 downto 0);                                                                                                                                                               
      keys_o     : out std_logic_vector(2 downto 0)  
    );
  end component;

  --SINAIS INTERNOS
  signal reset : std_logic;

  -- SINAL DOS BOTOES
  signal chaves_diretas    : std_logic_vector(2 downto 0); -- leitura dos botoes apenas
  signal chaves_estabilizadas : std_logic_vector(2 downto 0); -- leitura dos botoes sincronizados
  signal s_ajuste  : std_logic; -- sinal de ajuste para prox estado
  signal s_mais   : std_logic; -- incrementa
  signal s_menos   : std_logic; -- decrementa

  -- HORAS QUE CHEGM DO TIMER
  signal horas_atuais : std_logic_vector(4 downto 0);
  signal minutos_atuais  : std_logic_vector(5 downto 0);
  signal segundos_atuais  : std_logic_vector(5 downto 0);

  -- SINAL DE AJUSTE QUE SAI DSA FSM E ENTRA TIMER
  signal fsm_saida_hora : std_logic_vector(4 downto 0);
  signal fsm_saida_min  : std_logic_vector(5 downto 0);
  signal fsm_saida_seg : std_logic_vector(5 downto 0);
  signal s_atualiza_timer     : std_logic;

  -- SINAL DO BLINK
  signal blink_h, 
         blink_m, 
         blink_s          : std_logic;
  signal fsm_any_blink    : std_logic;
  signal blink_oscillator : std_logic;

  -- BCD PARA O DISPLAY
  signal hourT, hourU : std_logic_vector(3 downto 0);
  signal minT, minU   : std_logic_vector(3 downto 0);
  signal secT, secU   : std_logic_vector(3 downto 0);
  
  signal hourT_blink, 
         hourU_blink  : std_logic_vector(3 downto 0);
  signal minT_blink, 
         minU_blink   : std_logic_vector(3 downto 0);
  signal secT_blink, 
         secU_blink   : std_logic_vector(3 downto 0);

begin

  -- RST
  reset <= not KEY(0);
  
  -- BOTOES INVERTIDOS E VAO PARA SRINCONIZADOR
  chaves_diretas(0) <= not KEY(1); -- AJUSTE
  chaves_diretas(1) <= not KEY(2); -- MAIS
  chaves_diretas(2) <= not KEY(3); -- MENOIS

  -- SINCRONIZANDO AS TECLAS
  u_sincronizador: sync_keys
  port map(
    clk    => CLOCK_50,
    reset  => reset,
    keys_i => chaves_diretas,
    keys_o => chaves_estabilizadas
  );

  --   -- DPS DE SINCORNIZAR, PEGA CADA SINAL
  s_ajuste <= chaves_estabilizadas(0);
  s_mais  <= chaves_estabilizadas(1);
  s_menos  <= chaves_estabilizadas(2);

  -- LIGANDO COMPONENSTES DA FSM
  u_controle_fsm: fsm_relogio
  port map(
    clk      => CLOCK_50,
    reset    => reset,
    adjust   => s_ajuste,
    plus     => s_mais,
    less     => s_menos,
    
    -- FSM VE A HORA ATUAL DO TIMER
    hour_in  => horas_atuais,
    min_in   => minutos_atuais,
    seg_in   => segundos_atuais,
    
    -- FSM CONTROLE DE DISPLAY E CARREGAMENTO DO TIME
    blink_h  => blink_h,
    blink_m  => blink_m,
    blink_s  => blink_s,
    load     => s_atualiza_timer,
    
    -- FSM REPOEM HORA AJUSTADA NO TIMER
    hour_out => fsm_saida_hora,
    min_out  => fsm_saida_min,
    seg_out  => fsm_saida_seg
  );

  -- GERANDO TIMER
  u_contador_tempo: timer
  port map(
    clk    => CLOCK_50,
    reset  => reset,
    
    -- SINAIS DA FMS
    load   => s_atualiza_timer,
    hour_i => fsm_saida_hora,
    min_i  => fsm_saida_min,
    sec_i  => fsm_saida_seg,
    
    -- AQUI ENVIA A HORA ATUALIZADA PARA DISPLAY E FSM LER
    hour   => horas_atuais,
    min    => minutos_atuais,
    sec    => segundos_atuais
  );

  -- PISCA SE QUALQUER UM ESTIVER SOLICITADO
  fsm_any_blink <= blink_h or blink_m or blink_s;

  u_gerador_pisca: blink
  port map(
    clk   => CLOCK_50,
    reset => reset,
    en    => fsm_any_blink, 
    blink => blink_oscillator
  );
  
  secU_blink <= (others=>'1') when (blink_oscillator='1' and blink_s='1') else 
                secU;
  secT_blink <= (others=>'1') when (blink_oscillator='1' and blink_s='1') else 
                secT;
  
  minU_blink <= (others=>'1') when (blink_oscillator='1' and blink_m='1') else 
                minU;
  minT_blink <= (others=>'1') when (blink_oscillator='1' and blink_m='1') else 
                minT;
  
  hourU_blink <= (others=>'1') when (blink_oscillator='1' and blink_h='1') else 
                 hourU;
  hourT_blink <= (others=>'1') when (blink_oscillator='1' and blink_h='1') else 
                 hourT;

  bin2bcd_sec: bin2bcd 
  generic map (
    N => 6)
  port map (
    clk       => CLOCK_50, 
    reset     => reset, 
    binary_in => segundos_atuais, 
    bcd0      => secU, 
    bcd1      => secT, 
    bcd2      => open, 
    bcd3      => open, 
    bcd4      => open);

  bin2bcd_min: bin2bcd 
  generic map (
    N => 6)
  port map (
    clk       => CLOCK_50, 
    reset     => reset, 
    binary_in => minutos_atuais, 
    bcd0      => minU, 
    bcd1      => minT, 
    bcd2      => open, 
    bcd3      => open, 
    bcd4      => open);

  bin2bcd_hour: bin2bcd 
  generic map (
    N => 5)
  port map (
    clk       => CLOCK_50, 
    reset     => reset, 
    binary_in => horas_atuais, 
    bcd0      => hourU, 
    bcd1      => hourT, 
    bcd2      => open, 
    bcd3      => open, 
    bcd4      => open);

  bcd_secU : bcd2ssd 
  port map(
    BCD => secU_blink, 
    SSD => HEX0);

  bcd_secT : bcd2ssd 
  port map(
    BCD => secT_blink, 
    SSD => HEX1);

  bcd_minU : bcd2ssd 
  port map(
    BCD => minU_blink, 
    SSD => HEX2);

  bcd_minT : bcd2ssd 
  port map(
    BCD => minT_blink, 
    SSD => HEX3);

  bcd_hourU : bcd2ssd 
  port map(
    BCD => hourU_blink, 
    SSD => HEX4);

  bcd_hourT : bcd2ssd 
  port map(
    BCD => hourT_blink, 
    SSD => HEX5);   

end top;