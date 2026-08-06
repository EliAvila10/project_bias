with Ada.Numerics.Elementary_Functions;
with BcryptGenRandom_Wrapper;
with ProcessPrng_Wrapper;
with Math_Functions;
with Interfaces.C;
use Interfaces.C;

package body Chain_Generator with SPARK_Mode => On is

   use BcryptGenRandom_Wrapper;
   use ProcessPrng_Wrapper;
   use Math_Functions;

   function Dynamic_Length (Len : Positive) return Need_Function is
   begin
      case Len is
         when 1 .. 500 =>
            return R_1;
         when 501 .. 1000 =>
            return R_2;
         when 1001 .. 2500 =>
            return R_3;
         when 2501 .. 5000 =>
            return R_4;
         when 5001 .. 7500 =>
            return R_5;
         when 7501 .. 10000 =>
            return R_6;
         when others =>
            return R_7;
      end case;
   end Dynamic_Length;

   procedure Calculate_Shannon_Entropy (Item : String;
                                        Ento : in out sub_entropy) is

      subtype counter_array_nat is Natural range 0 .. Item'Length;
      type Counter_Array is array (Character) of counter_array_nat;

      Counter     : Counter_Array := (others => 0);
      Item_Length : constant Positive := Item'Length;

      function Division (Nat : Natural) return Float
        with Pre  => Nat > 0 and then Nat <= Item_Length,
        Post => Division'Result = (Float'Min (Float'Max (Float (Nat)
                                   / Float (Item_Length), 0.0002), 1.0))
      is
      begin
         return (Float'Min (Float'Max (Float (Nat)
                 / Float (Item_Length), 0.0002), 1.0));
      end Division;

      function Shannon_Base2 (Pat : Float) return Float
        with Pre  => Pat >= 0.0002 and then Pat <= 1.0,
        Post => Shannon_Base2'Result >= 0.0
        and then Shannon_Base2'Result <= 12.3
      is
      begin
         return (Float'Min (Float'Max
                 (-Ada.Numerics.Elementary_Functions.Log
                    (Pat, 2.0), 0.0), 12.3));
      end Shannon_Base2;

   begin

      for I in Item'First .. Item'Last loop

         pragma Loop_Variant   (Increases => I);
         pragma Loop_Invariant (I in Item'First .. Item'Last);

         pragma Loop_Invariant (for all J in Counter'Range =>
                                  Counter (J) <= Item_Length);

         pragma Loop_Invariant (for all J in Counter'Range =>
                                  Counter (J) <= Natural (if I = Item'First
                                  then 0 else I - Item'First));

         Counter (Item (I)) := Counter (Item (I)) + 1;
      end loop;

      for I in Counter'First .. Counter'Last loop

         pragma Loop_Variant   (Increases => I);
         pragma Loop_Invariant (Ento in 0.0 .. 8.0);

         if Counter (I) > 0 then
            Ento := sub_entropy (Float'Min (Float'Max (Float (Ento) +
                                 (Division (Counter (I))
                                    * Shannon_Base2 (Division (Counter (I)))),
                                 0.0), 8.0));
         end if;
      end loop;

   end Calculate_Shannon_Entropy;

   --=========================================================================-

   ------------------------------
   -- Chain_Alphanumeric_Mixed --
   ------------------------------
   procedure Chain_Alphanumeric_Mixed (Chain   : in out Alphanumeric_Mixed;
                                       Success :    out NTSTATUS;
                                       Works   : in out Boolean;
                                       Entropy : in out sub_entropy)
   is
      Chain_Set : constant Alphanumeric_Mixed (1 .. 69) :=
        "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#%_*-";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len    : size_t range Rnd_Buffer'First .. Rnd_Buffer'Length
        := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      Sesgo      : constant Sesgo_Free := Unbiased_Secure
        (Len => Chain_Set'Length);

      subtype Unbiased is Interfaces.Unsigned_8 range 0 ..
        Interfaces.Unsigned_8 (Sesgo);

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len         := Chain_Len + 1;

            Chain (Chain_Len) :=
              Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                         mod Chain_Set'Length) + 1);

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Alphanumeric_Mixed;

   ------------------------
   -- Chain_Alphanumeric --
   ------------------------
   procedure Chain_Alphanumeric (Chain   : in out Alphanumeric_Simple;
                                 Success :    out NTSTATUS;
                                 Works   : in out Boolean;
                                 Entropy : in out sub_entropy)
   is

      Chain_Set  : constant Alphanumeric_Simple (1 .. 62)
        := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len    : size_t range Rnd_Buffer'First .. Rnd_Buffer'Length
        := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      Sesgo      : constant Sesgo_Free := Unbiased_Secure
        (Len => Chain_Set'Length);

      subtype Unbiased is Interfaces.Unsigned_8 range 0 ..
        Interfaces.Unsigned_8 (Sesgo);

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len         := Chain_Len + 1;

            Chain (Chain_Len) :=
              Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                         mod Chain_Set'Length) + 1);

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Alphanumeric;

   ------------------------
   -- Chain_Only_Numbers --
   ------------------------
   procedure Chain_Only_Numbers (Chain   : in out Only_Numbers;
                                 Success :    out NTSTATUS;
                                 Works   : in out Boolean;
                                 Entropy : in out sub_entropy)
   is

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len    : size_t range Rnd_Buffer'First .. Rnd_Buffer'Length
        := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      subtype Unbiased is Interfaces.Unsigned_8 range 0 .. 249;

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len        := Chain_Len + 1;

            pragma Assert
              (Character'Val
                 (Character'Pos ('0') +
                      Natural (Rnd_Buffer (Rnd_Len)) mod 10)
               in '0' .. '9');

            Chain (Chain_Len)
              := Character'Val (Character'Pos ('0') +
                                (Natural (Rnd_Buffer (Rnd_Len)) mod 10));

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Only_Numbers;

   --------------------------
   -- Chain_Only_Uppercase --
   --------------------------
   procedure Chain_Only_Uppercase  (Chain   : in out Only_Uppercase;
                                    Success :    out NTSTATUS;
                                    Works   : in out Boolean;
                                    Entropy : in out sub_entropy)
   is

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                    : size_t range Rnd_Buffer'First
        .. Rnd_Buffer'Length := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      subtype Unbiased is Interfaces.Unsigned_8 range 0 .. 233;

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len        := Chain_Len + 1;

            pragma Assert
              (Character'Val
                 (Character'Pos ('A') +
                      Natural (Rnd_Buffer (Rnd_Len)) mod 26)
               in 'A' .. 'Z');

            Chain (Chain_Len)
              := Character'Val (Character'Pos ('A') +
                                (Natural (Rnd_Buffer (Rnd_Len)) mod 26));

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Only_Uppercase;

   --------------------------
   -- Chain_Only_Lowercase --
   --------------------------
   procedure Chain_Only_Lowercase (Chain   : in out Only_Lowercase;
                                   Success :    out NTSTATUS;
                                   Works   : in out Boolean;
                                   Entropy : in out sub_entropy)
   is

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                    : size_t range Rnd_Buffer'First
        .. Rnd_Buffer'Length := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      subtype Unbiased is Interfaces.Unsigned_8 range 0 .. 233;

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len        := Chain_Len + 1;

            pragma Assert
              (Character'Val
                 (Character'Pos ('a') +
                      Natural (Rnd_Buffer (Rnd_Len)) mod 26)
               in 'a' .. 'z');

            Chain (Chain_Len)
              := Character'Val (Character'Pos ('a') +
                                (Natural (Rnd_Buffer (Rnd_Len)) mod 26));

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Only_Lowercase;

   ------------------------
   -- Chain_Only_Letters --
   ------------------------
   procedure Chain_Only_Letters (Chain   : in out Only_Letters;
                                 Success :    out NTSTATUS;
                                 Works   : in out Boolean;
                                 Entropy : in out sub_entropy)
   is

      Chain_Set  : constant Only_Letters (1 .. 52)
        := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                    : size_t range Rnd_Buffer'First
        .. Rnd_Buffer'Length := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      Sesgo      : constant Sesgo_Free := Unbiased_Secure
        (Len => Chain_Set'Length);

      subtype Unbiased is Interfaces.Unsigned_8 range 0 ..
        Interfaces.Unsigned_8 (Sesgo);

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len         := Chain_Len + 1;

            Chain (Chain_Len) :=
              Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                         mod Chain_Set'Length) + 1);

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Only_Letters;

   ------------------------
   -- Chain_Only_Symbols --
   ------------------------
   procedure Chain_Only_Symbols (Chain   : in out Only_Symbols;
                                 Success :    out NTSTATUS;
                                 Works   : in out Boolean;
                                 Entropy : in out sub_entropy)
   is

      Chain_Set : constant Only_Symbols (1 .. 7) := "!@#%_*-";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                    : size_t range Rnd_Buffer'First
        .. Rnd_Buffer'Length := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      Sesgo      : constant Sesgo_Free := Unbiased_Secure
        (Len => Chain_Set'Length);

      subtype Unbiased is Interfaces.Unsigned_8 range 0 ..
        Interfaces.Unsigned_8 (Sesgo);

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len         := Chain_Len + 1;

            Chain (Chain_Len) :=
              Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                         mod Chain_Set'Length) + 1);

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Only_Symbols;

   ----------------------------
   -- Chain_Number_Uppercase --
   ----------------------------
   procedure Chain_Number_Uppercase (Chain   : in out Only_N_U;
                                     Success :    out NTSTATUS;
                                     Works   : in out Boolean;
                                     Entropy : in out sub_entropy)
   is

      Chain_Set  : constant Only_N_U (1 .. 36)
        := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                    : size_t range Rnd_Buffer'First
        .. Rnd_Buffer'Length := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      Sesgo      : constant Sesgo_Free := Unbiased_Secure
        (Len => Chain_Set'Length);

      subtype Unbiased is Interfaces.Unsigned_8 range 0 ..
        Interfaces.Unsigned_8 (Sesgo);

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len         := Chain_Len + 1;

            Chain (Chain_Len) :=
              Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                         mod Chain_Set'Length) + 1);

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Number_Uppercase;

   ----------------------------
   -- Chain_Number_Lowercase --
   ----------------------------
   procedure Chain_Number_Lowercase (Chain   : in out Only_N_L;
                                     Success :    out NTSTATUS;
                                     Works   : in out Boolean;
                                     Entropy : in out sub_entropy)
   is

      Chain_Set  : constant Only_N_L (1 .. 36)
        := "0123456789abcdefghijklmnopqrstuvwxyz";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                    : size_t range Rnd_Buffer'First
        .. Rnd_Buffer'Length := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      Sesgo      : constant Sesgo_Free := Unbiased_Secure
        (Len => Chain_Set'Length);

      subtype Unbiased is Interfaces.Unsigned_8 range 0 ..
        Interfaces.Unsigned_8 (Sesgo);

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len         := Chain_Len + 1;

            Chain (Chain_Len) :=
              Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                         mod Chain_Set'Length) + 1);

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Number_Lowercase;

   -------------------------
   -- Chain_Hex_Lowercase --
   -------------------------
   procedure Chain_Hex_Lowercase (Chain   : in out Hex_Lowercase;
                                  Success :    out NTSTATUS;
                                  Works   : in out Boolean;
                                  Entropy : in out sub_entropy)
   is

      Chain_Set : constant Hex_Lowercase (1 .. 16) :=
        "0123456789abcdef";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                               (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                                    : size_t range
        Rnd_Buffer'First .. Rnd_Buffer'Length      := Rnd_Buffer'First;
      Chain_Len                                  :
      Natural range 0 .. Chain'Length := 0;

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant (Increases => Chain_Len);
         pragma Loop_Variant (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         Chain_Len         := Chain_Len + 1;

         Chain (Chain_Len) :=
           Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                      mod Chain_Set'Length) + 1);

         Rnd_Len           := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);

   end Chain_Hex_Lowercase;

   -------------------------
   -- Chain_Hex_Uppercase --
   -------------------------
   procedure Chain_Hex_Uppercase (Chain   : in out Hex_Uppercase;
                                  Success :    out NTSTATUS;
                                  Works   : in out Boolean;
                                  Entropy : in out sub_entropy)
   is

      Chain_Set : constant Hex_Uppercase (1 .. 16) :=
        "0123456789ABCDEF";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                                    : size_t range
        Rnd_Buffer'First .. Rnd_Buffer'Length      := Rnd_Buffer'First;

      Chain_Len                                  :
      Natural range 0 .. Chain'Length := 0;

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant (Increases => Chain_Len);
         pragma Loop_Variant (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         Chain_Len         := Chain_Len + 1;

         Chain (Chain_Len) :=
           Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                      mod Chain_Set'Length) + 1);

         Rnd_Len           := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);

   end Chain_Hex_Uppercase;

   ------------------------------
   -- Chain_Compact_Industrial --
   ------------------------------
   procedure Chain_Compact_Industrial (Chain   : in out Compact_Industrial;
                                       Success :    out NTSTATUS;
                                       Works   : in out Boolean;
                                       Entropy : in out sub_entropy)
   is
      Chain_Set : constant Compact_Industrial (1 .. 44) :=
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!._-*+=~";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                    : size_t range Rnd_Buffer'First
        .. Rnd_Buffer'Length := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      Sesgo      : constant Sesgo_Free := Unbiased_Secure
        (Len => Chain_Set'Length);

      subtype Unbiased is Interfaces.Unsigned_8 range 0 ..
        Interfaces.Unsigned_8 (Sesgo);

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len         := Chain_Len + 1;

            Chain (Chain_Len) :=
              Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                         mod Chain_Set'Length) + 1);

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Compact_Industrial;

   --------------------------
   -- Chain_Human_Readable --
   --------------------------
   procedure Chain_Human_Readable (Chain   : in out Human_Readable;
                                   Success :    out NTSTATUS;
                                   Works   : in out Boolean;
                                   Entropy : in out sub_entropy)
   is
      Chain_Set : constant Human_Readable (1 .. 58) :=
        "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                    : size_t range Rnd_Buffer'First
        .. Rnd_Buffer'Length := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      Sesgo      : constant Sesgo_Free := Unbiased_Secure
        (Len => Chain_Set'Length);

      subtype Unbiased is Interfaces.Unsigned_8 range 0 ..
        Interfaces.Unsigned_8 (Sesgo);

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len         := Chain_Len + 1;

            Chain (Chain_Len) :=
              Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                         mod Chain_Set'Length) + 1);

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Human_Readable;

   -------------------
   -- Chain_Safe_Token --
   -------------------
   procedure Chain_Safe_Token (Chain   : in out Safe_Token;
                               Success :    out NTSTATUS;
                               Works   : in out Boolean;
                               Entropy : in out sub_entropy)
   is
      Chain_Set : constant Safe_Token (1 .. 64) :=
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

      New_Length : constant Positive := Dynamic_Length (Len => Chain'Length);

      Rnd_Buffer : BUFFER_RNG (0 .. BUFFER_RNG_LENGTH
                              (Chain'Length + New_Length) - 1)
        := (others => 0);

      Rnd_Len                    : size_t range Rnd_Buffer'First
        .. Rnd_Buffer'Length := Rnd_Buffer'First;

      Chain_Len  : Natural range 0 .. Chain'Length := 0;

      Sesgo      : constant Sesgo_Free := Unbiased_Secure
        (Len => Chain_Set'Length);

      subtype Unbiased is Interfaces.Unsigned_8 range 0 ..
        Interfaces.Unsigned_8 (Sesgo);

   begin

      Success    := NTSTATUS'Last;

      ProcessPrng_Public (Buffer => Rnd_Buffer,
                         Status => Success);

      if Success /= 1 then

         Success  := NTSTATUS'Last;

         BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                Status => Success);

         if Success /= 0 then
            return;
         else
            Works := (Success = 0);
         end if;

      else
         Works := (Success = 1);
      end if;

      while Chain_Len < Chain'Length and then Rnd_Len < Rnd_Buffer'Length loop

         pragma Loop_Variant   (Increases => Rnd_Len);
         pragma Loop_Invariant (Chain_Len in 0 .. Chain'Length);
         pragma Loop_Invariant (Rnd_Len in Rnd_Buffer'First
                                .. Rnd_Buffer'Length);

         if Rnd_Buffer (Rnd_Len) in Unbiased then

            Chain_Len         := Chain_Len + 1;

            Chain (Chain_Len) :=
              Chain_Set ((Natural (Rnd_Buffer (Rnd_Len))
                         mod Chain_Set'Length) + 1);

         end if;

         Rnd_Len := Rnd_Len + 1;

      end loop;

      Rnd_Buffer := (others => 0);
      pragma Unreferenced (Rnd_Buffer);

      Calculate_Shannon_Entropy (Item => Chain,
                                Ento => Entropy);
   end Chain_Safe_Token;

end Chain_Generator;
