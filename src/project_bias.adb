with Ada.Text_IO;
with Ada.Float_Text_IO;

with Windows_Data_Types;
with Interfaces;
with Interfaces.C;

with ProcessPrng_Wrapper;
with BcryptGenRandom_Wrapper;

with Chain_Generator;
with get_time;

with Chain_Test;

procedure Project_Bias is
   use Chain_Generator;

   use Windows_Data_Types;
   use Interfaces;
   use Interfaces.C;

   New_Chain   : String (1 .. 96)  := (others => '0');
   New_Success : Interfaces.C.long := Interfaces.C.long'Last;
   New_Works   : Boolean           := False;
   New_Entropy : Float             := 0.0;

   procedure Show_Info_Chains (C   : in out String;
                               N   : String;
                               S   : in out Interfaces.C.long;
                               W   : in out Boolean;
                               E   : in out Float)
   is

   begin

      if S = 1 and then W then
         Ada.Text_IO.Put_Line
           (Item => "Api ProcessPrng Status =>" & Interfaces.C.long'Image (S));
         Ada.Text_IO.Put_Line (Item => "New Chain Name          => " & N);
         Ada.Text_IO.Put_Line
           (Item => "New Chain Created       => " & C);
         Ada.Text_IO.Put
           (Item => "New Chain Entropy       => ");
         Ada.Float_Text_IO.Put (Item => E,
                                Fore => 1,
                                Aft  => 6,
                                Exp  => 0);
      end if;

      if S = 0 and then W then
         Ada.Text_IO.Put_Line
           (Item => "Api BcryptGenRandom Status =>"
            & Interfaces.C.long'Image (S));
         Ada.Text_IO.Put_Line
           (Item => "New Chain Name                    => " & N);
         Ada.Text_IO.Put_Line
           (Item => "New Chain Created                 => " & C);
         Ada.Text_IO.Put
           (Item => "New Chain Entropy                 => ");
         Ada.Float_Text_IO.Put (Item => E,
                                Fore => 1,
                                Aft  => 6,
                                Exp  => 0);
      end if;

      Ada.Text_IO.New_Line;
      Ada.Text_IO.New_Line;

      C := (others => '0');
      S := Interfaces.C.long'Last;
      W := False;
      E := 0.0;

   end Show_Info_Chains;

   procedure Show_Info_Get_Time is

      Get_New_Date   : get_time.new_date_d := (others => '0');
      Get_New_Day    : get_time.new_day_d  := (others => 'o');
      Get_New_Hour   : get_time.new_hour_h := (others => '0');

      Get_New_Format : get_time.new_form_f := (others => '0');
      Get_New_AM_PM  : get_time.am_pm_form := (others => '0');

   begin
      Ada.Text_IO.New_Line;

      get_time.get_date   (Date => Get_New_Date);
      get_time.get_day    (Day  => Get_New_Day);
      get_time.get_hour   (Hour => Get_New_Hour);

      get_time.get_format (Format_Str => Get_New_Format,
                           AAMM_PPMM  => Get_New_AM_PM,
                           Option     => 1);

      Ada.Text_IO.Put_Line (Item => "Date    : " & Get_New_Date);
      Ada.Text_IO.Put_Line (Item => "Day      : " & Get_New_Day);
      Ada.Text_IO.Put_Line (Item => "Hour    : " & Get_New_Hour);
      Ada.Text_IO.Put_Line (Item => "Format : " & Get_New_Format);

      Get_New_Format := (others => '0'); -- clean always before second call

      get_time.get_format (Format_Str => Get_New_Format,
                           AAMM_PPMM  => Get_New_AM_PM,
                           Option     => 2);

      Ada.Text_IO.Put_Line (Item => "AM/PM : " & Get_New_AM_PM);

      Get_New_AM_PM := (others => '0'); -- clean always before second call
      pragma Unreferenced (Get_New_AM_PM);

      Ada.Text_IO.New_Line;

   end Show_Info_Get_Time;

   procedure Show_Info_Process_PRNG is
      Buffer_Process  : BUFFER_RNG (0 .. 32) := (others => 0);
      Process_Success : NTSTATUS            := NTSTATUS'Last;

   begin

      ProcessPrng_Wrapper.ProcessPrng_Public (Buffer => Buffer_Process,
                                             Status => Process_Success);

      if Process_Success /= 1 then
         return;
      end if;

      Ada.Text_IO.Put (Item => "ProcessPrng Bytes Pure           =>");
      for I in Buffer_Process'Range loop
         Ada.Text_IO.Put
           (Item => Interfaces.Unsigned_8'Image (Buffer_Process (I)));
      end loop;

      Ada.Text_IO.Put_Line (Item => "");

   end Show_Info_Process_PRNG;

   procedure Show_Info_BCryptRandom is
      Buffer_Bcrypt  : BUFFER_RNG (0 .. 32) := (others => 0);
      Bcrypt_Success : NTSTATUS            := NTSTATUS'Last;

   begin

      BcryptGenRandom_Wrapper.BcryptGenRandom_Public (Buffer => Buffer_Bcrypt,
                                                     Status => Bcrypt_Success);

      if Bcrypt_Success /= 0 then
         return;
      end if;

      Ada.Text_IO.Put (Item => "BCryptGenRandom Bytes Pure =>");
      for I in Buffer_Bcrypt'Range loop
         Ada.Text_IO.Put
           (Item => Interfaces.Unsigned_8'Image (Buffer_Bcrypt (I)));
      end loop;

      Ada.Text_IO.New_Line;
      Ada.Text_IO.New_Line;
   end Show_Info_BCryptRandom;

begin

   Show_Info_Get_Time;
   Show_Info_Process_PRNG;
   Show_Info_BCryptRandom;

   for I in 1 .. 14 loop
      Chain_Test.Chain_Public_Test (Loops  => 25_000,
                                    Option => I);
   end loop;

   Ada.Text_IO.New_Line;

   for I in 1 .. 14 loop

      case I is
         when 1  =>
            Chain_Alphanumeric_Mixed (Chain   => New_Chain,
                                      Success => New_Success,
                                      Works   => New_Works,
                                      Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Alphanumeric Mixed",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 2  =>
            Chain_Alphanumeric (Chain   => New_Chain,
                                Success => New_Success,
                                Works   => New_Works,
                                Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Alphanumeric",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 3  =>
            Chain_Only_Numbers (Chain   => New_Chain,
                                Success => New_Success,
                                Works   => New_Works,
                                Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Only Numbers",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 4  =>
            Chain_Only_Uppercase (Chain   => New_Chain,
                                  Success => New_Success,
                                  Works   => New_Works,
                                  Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Only Uppercase",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 5  =>
            Chain_Only_Lowercase (Chain   => New_Chain,
                                  Success => New_Success,
                                  Works   => New_Works,
                                  Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Only Lowercase",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 6  =>
            Chain_Only_Letters (Chain   => New_Chain,
                                Success => New_Success,
                                Works   => New_Works,
                                Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Only Letters",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 7  =>
            Chain_Only_Symbols (Chain   => New_Chain,
                                Success => New_Success,
                                Works   => New_Works,
                                Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Only Symbols",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 8  =>
            Chain_Number_Uppercase (Chain   => New_Chain,
                                    Success => New_Success,
                                    Works   => New_Works,
                                    Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Number Uppercase",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 9  =>
            Chain_Number_Lowercase (Chain   => New_Chain,
                                    Success => New_Success,
                                    Works   => New_Works,
                                    Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Number Lowercase",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 10 =>
            Chain_Hex_Lowercase (Chain   => New_Chain,
                                 Success => New_Success,
                                 Works   => New_Works,
                                 Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Hex Lowercase",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 11 =>
            Chain_Hex_Uppercase (Chain   => New_Chain,
                                 Success => New_Success,
                                 Works   => New_Works,
                                 Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Hex Uppercase",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 12 =>
            Chain_Compact_Industrial (Chain   => New_Chain,
                                      Success => New_Success,
                                      Works   => New_Works,
                                      Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Compact Industrial",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 13 =>
            Chain_Human_Readable (Chain   => New_Chain,
                                  Success => New_Success,
                                  Works   => New_Works,
                                  Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Human Readable",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
         when 14 =>
            Chain_Safe_Token (Chain   => New_Chain,
                              Success => New_Success,
                              Works   => New_Works,
                              Entropy => New_Entropy);

            Show_Info_Chains (C => New_Chain,
                              N => "Chain Safe Token",
                              S => New_Success,
                              W => New_Works,
                              E => New_Entropy);
      end case;
   end loop;

end Project_Bias;
