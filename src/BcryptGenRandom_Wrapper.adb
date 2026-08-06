package body BcryptGenRandom_Wrapper with SPARK_Mode => off is

   procedure BcryptGenRandom_Public
     (Buffer : in out BUFFER_RNG;
      Status : in out NTSTATUS)
   is

   begin

      BGR :
      for I in reverse 1 .. 5 loop

         pragma Loop_Variant   (Decreases => I);
         pragma Loop_Invariant (I in 1 .. 5);

         Status := BCryptGenRandom
           (pbBuffer => Buffer (Buffer'First)'Address,
            cbBuffer => ULONG (Buffer'Length));

         exit BGR when Status = BCRYPT_SUCCESS;

         SecureZeroMemory
           (Address => Buffer (Buffer'First)'Address,
            Size    => BUFFER_RNG_LENGTH (Buffer'Length));

         Buffer := (others => 0);

         Retry  := Ada.Real_Time.Clock + Interval;
         delay until Retry;

      end loop BGR;

   end BcryptGenRandom_Public;

end BcryptGenRandom_Wrapper;
