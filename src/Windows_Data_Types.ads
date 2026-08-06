with Interfaces;
with Interfaces.C;
with System;

package Windows_Data_Types is

   subtype System_Address is System.Address;
   subtype HANDLE         is System.Address;
   subtype PVOID          is System.Address;

   subtype UCHAR          is Interfaces.Unsigned_8;
   subtype ULONG          is Interfaces.C.unsigned_long;
   subtype NTSTATUS       is Interfaces.C.long;

   subtype BUFFER_RNG_LENGTH is Interfaces.C.size_t;
   type BUFFER_RNG is array (BUFFER_RNG_LENGTH range <>) of UCHAR
     with Convention => C;

end Windows_Data_Types;
