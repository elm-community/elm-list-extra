module List.NDet
  ( NDet
  , none
  , some
  , fromList
  , toList
  , map
  , andMap
  , andThen
  ) where
{-| A list-based nondeterminstic value. Also useful for carthesian product
combinations. Note that this is a very simple wrapper, it doesn't get rid of
values that are equal.

# NDet construction/deconstruction
@docs none, some, fromList, toList

# Mapping and more
@docs map, map2, map3, andMap, andThen

-}
import List
import List.Extra as List

type alias NDet a = List a

{-| A lack of values.
-}
none : NDet a
none = []

{-| Build a nondeterministic value out of a normal value.
-}
some : a -> NDet a
some a = [a]

{-| Build a nondeterministic value out of a list of possibilities.
-}
fromList : List a -> NDet a
fromList l = l

{-| Show the nondeterministic value as a list of possibilities.
-}
toList : NDet a -> List a
toList nd = nd

{-| Apply a function to a nondeterministic value:

```
[1,2,3] |> fromList >> map ((+) 1) >> toList == [2,3,4]
```
-}
map : (a -> b) -> NDet a -> NDet b
map f nd = List.map f nd

{-| Sequence some nondeterministic operations:

```
fromList [1,2,3] `andThen` \x ->
fromList [1,2,3] `andThen` \y -> (x,y)
|> toList
== [ (1,1),(1,2),(1,3)
   , (2,1),(2,2),(2,3)
   , (3,1),(3,2),(3,3)
   ]
```
-}
andThen : NDet a -> (a -> NDet b) -> NDet b
andThen nd bind = List.concatMap bind nd

{-| Useful for applying multiple functions to nondeterministic values:

```
toList
  (map (+) (fromList [1,2,3])
     `andMap` (fromList [1,2,3]))
== [2,3,4,3,4,5,4,5,6]
```
-}
andMap : NDet (a -> b) -> NDet a -> NDet b
andMap nf nd = nf `andThen` (\f -> nd `andThen` (some << f))
