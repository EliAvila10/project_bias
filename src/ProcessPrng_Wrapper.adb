package body ProcessPrng_Wrapper with SPARK_Mode => Off is

   procedure ProcessPrng_Public
     (Buffer : in out BUFFER_RNG;
      Status : in out NTSTATUS)
   is
   begin

      if ProcessPrng'Address /= System.Null_Address then

         PPG :
         for I in reverse 1 .. 5 loop

            pragma Loop_Variant   (Decreases => I);
            pragma Loop_Invariant (I in 1 .. 5);

            Status := ProcessPrng
              (pbData => Buffer (Buffer'First)'Address,
               cbData => BUFFER_RNG_LENGTH (Buffer'Length));

            exit PPG when Status = ProcessPrng_Success;

            SecureZeroMemory
              (Address => Buffer (Buffer'First)'Address,
               Size    => BUFFER_RNG_LENGTH (Buffer'Length));

            Buffer := (others => 0);

            Retry  := Ada.Real_Time.Clock + Interval;
            delay until Retry;

         end loop PPG;

      else
         Status := NTSTATUS'Last;
         return;
      end if;

   end ProcessPrng_Public;
end ProcessPrng_Wrapper;
