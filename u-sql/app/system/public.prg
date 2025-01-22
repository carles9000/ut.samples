//----------------------------------------------------------------------------//

function aGetWorkAreas()     // Returns an Array with all available Alias

   local aAreas := {}
   local n

   for n = 1 to 255
      if ! Empty( Alias( n ) )
         AAdd( aAreas, Alias( n ) )
      endif
   next

return aAreas

//----------------------------------------------------------------------------//