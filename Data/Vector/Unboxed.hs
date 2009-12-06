module Data.Vector.Unboxed (
  Vector, MVector(..), Unbox,

  -- * Length information
  length, null,

  -- * Construction
  empty, singleton, cons, snoc, replicate, (++), copy,

  -- * Accessing individual elements
  (!), head, last,
  unsafeIndex,

  -- * Subvectors
  slice, init, tail, take, drop,
  unsafeSlice,

  -- * Permutations
  accum, accumulate_, (//), update_, backpermute, reverse,

  -- * Mapping
  map, concatMap,

  -- * Zipping and unzipping
  zipWith, zipWith3,
  zip, zip3, zip4, zip5, zip6, zip7, zip8, zip9, zip10, zip11, zip12,
  unzip, unzip3, unzip4, unzip5, unzip6, unzip7, unzip8, unzip9, unzip10,
  unzip11, unzip12,

  -- * Filtering
  filter, takeWhile, dropWhile,

  -- * Searching
  elem, notElem, find, findIndex,

  -- * Folding
  foldl, foldl1, foldl', foldl1', foldr, foldr1,

  -- * Specialised folds
  sum, product, maximum, minimum,

  -- * Unfolding
  unfoldr,

  -- * Scans
  prescanl, prescanl',
  postscanl, postscanl',
  scanl, scanl', scanl1, scanl1',

  -- * Enumeration
  enumFromTo, enumFromThenTo,

  -- * Conversion to/from lists
  toList, fromList
) where

import Data.Vector.Unboxed.Base
import qualified Data.Vector.Generic as G

import Prelude hiding ( length, null,
                        replicate, (++),
                        head, last,
                        init, tail, take, drop, reverse,
                        map, concatMap,
                        zipWith, zipWith3, zip, zip3, unzip, unzip3,
                        filter, takeWhile, dropWhile,
                        elem, notElem,
                        foldl, foldl1, foldr, foldr1,
                        sum, product, minimum, maximum,
                        scanl, scanl1,
                        enumFromTo, enumFromThenTo )

-- Length
-- ------

length :: Unbox a => Vector a -> Int
{-# INLINE length #-}
length = G.length

null :: Unbox a => Vector a -> Bool
{-# INLINE null #-}
null = G.null

-- Construction
-- ------------

-- | Empty vector
empty :: Unbox a => Vector a
{-# INLINE empty #-}
empty = G.empty

-- | Vector with exaclty one element
singleton :: Unbox a => a -> Vector a
{-# INLINE singleton #-}
singleton = G.singleton

-- | Vector of the given length with the given value in each position
replicate :: Unbox a => Int -> a -> Vector a
{-# INLINE replicate #-}
replicate = G.replicate

-- | Prepend an element
cons :: Unbox a => a -> Vector a -> Vector a
{-# INLINE cons #-}
cons = G.cons

-- | Append an element
snoc :: Unbox a => Vector a -> a -> Vector a
{-# INLINE snoc #-}
snoc = G.snoc

infixr 5 ++
-- | Concatenate two vectors
(++) :: Unbox a => Vector a -> Vector a -> Vector a
{-# INLINE (++) #-}
(++) = (G.++)

-- | Create a copy of a vector. Useful when dealing with slices.
copy :: Unbox a => Vector a -> Vector a
{-# INLINE copy #-}
copy = G.copy

-- Accessing individual elements
-- -----------------------------

-- | Indexing
(!) :: Unbox a => Vector a -> Int -> a
{-# INLINE (!) #-}
(!) = (G.!)

-- | Unsafe indexing without bounds checks
unsafeIndex :: Unbox a => Vector a -> Int -> a
{-# INLINE unsafeIndex #-}
unsafeIndex = G.unsafeIndex

-- | First element
head :: Unbox a => Vector a -> a
{-# INLINE head #-}
head = G.head

-- | Last element
last :: Unbox a => Vector a -> a
{-# INLINE last #-}
last = G.last

-- Subarrays
-- ---------

-- | Yield a part of the vector without copying it. Safer version of
-- 'basicUnsafeSlice'.
slice :: Unbox a => Vector a -> Int   -- ^ starting index
                            -> Int   -- ^ length
                            -> Vector a
{-# INLINE slice #-}
slice = G.slice

-- | Unsafely yield a part of the vector without copying it and without
-- performing bounds checks.
unsafeSlice :: Unbox a => Vector a -> Int   -- ^ starting index
                                  -> Int   -- ^ length
                                  -> Vector a
{-# INLINE unsafeSlice #-}
unsafeSlice = G.unsafeSlice

-- | Yield all but the last element without copying.
init :: Unbox a => Vector a -> Vector a
{-# INLINE init #-}
init = G.init

-- | All but the first element (without copying).
tail :: Unbox a => Vector a -> Vector a
{-# INLINE tail #-}
tail = G.tail

-- | Yield the first @n@ elements without copying.
take :: Unbox a => Int -> Vector a -> Vector a
{-# INLINE take #-}
take = G.take

-- | Yield all but the first @n@ elements without copying.
drop :: Unbox a => Int -> Vector a -> Vector a
{-# INLINE drop #-}
drop = G.drop

-- Permutations
-- ------------

accum :: Unbox a => (a -> b -> a) -> Vector a -> [(Int,b)] -> Vector a
{-# INLINE accum #-}
accum = G.accum

accumulate_ :: (Unbox a, Unbox b) =>
               (a -> b -> a) -> Vector a -> Vector Int -> Vector b -> Vector a
{-# INLINE accumulate_ #-}
accumulate_ = G.accumulate_

(//) :: Unbox a => Vector a -> [(Int, a)] -> Vector a
{-# INLINE (//) #-}
(//) = (G.//)

update_ :: Unbox a => Vector a -> Vector Int -> Vector a -> Vector a
{-# INLINE update_ #-}
update_ = G.update_

backpermute :: Unbox a => Vector a -> Vector Int -> Vector a
{-# INLINE backpermute #-}
backpermute = G.backpermute

reverse :: Unbox a => Vector a -> Vector a
{-# INLINE reverse #-}
reverse = G.reverse

-- Mapping
-- -------

-- | Map a function over a vector
map :: (Unbox a, Unbox b) => (a -> b) -> Vector a -> Vector b
{-# INLINE map #-}
map = G.map

concatMap :: (Unbox a, Unbox b) => (a -> Vector b) -> Vector a -> Vector b
{-# INLINE concatMap #-}
concatMap = G.concatMap

-- Zipping/unzipping
-- -----------------

-- | Zip two vectors with the given function.
zipWith :: (Unbox a, Unbox b, Unbox c)
        => (a -> b -> c) -> Vector a -> Vector b -> Vector c
{-# INLINE zipWith #-}
zipWith = G.zipWith

-- | Zip three vectors with the given function.
zipWith3 :: (Unbox a, Unbox b, Unbox c, Unbox d)
         => (a -> b -> c -> d) -> Vector a -> Vector b -> Vector c -> Vector d
{-# INLINE zipWith3 #-}
zipWith3 = G.zipWith3

-- Filtering
-- ---------

-- | Drop elements which do not satisfy the predicate
filter :: Unbox a => (a -> Bool) -> Vector a -> Vector a
{-# INLINE filter #-}
filter = G.filter

-- | Yield the longest prefix of elements satisfying the predicate.
takeWhile :: Unbox a => (a -> Bool) -> Vector a -> Vector a
{-# INLINE takeWhile #-}
takeWhile = G.takeWhile

-- | Drop the longest prefix of elements that satisfy the predicate.
dropWhile :: Unbox a => (a -> Bool) -> Vector a -> Vector a
{-# INLINE dropWhile #-}
dropWhile = G.dropWhile

-- Searching
-- ---------

infix 4 `elem`
-- | Check whether the vector contains an element
elem :: (Unbox a, Eq a) => a -> Vector a -> Bool
{-# INLINE elem #-}
elem = G.elem

infix 4 `notElem`
-- | Inverse of `elem`
notElem :: (Unbox a, Eq a) => a -> Vector a -> Bool
{-# INLINE notElem #-}
notElem = G.notElem

-- | Yield 'Just' the first element matching the predicate or 'Nothing' if no
-- such element exists.
find :: Unbox a => (a -> Bool) -> Vector a -> Maybe a
{-# INLINE find #-}
find = G.find

-- | Yield 'Just' the index of the first element matching the predicate or
-- 'Nothing' if no such element exists.
findIndex :: Unbox a => (a -> Bool) -> Vector a -> Maybe Int
{-# INLINE findIndex #-}
findIndex = G.findIndex

-- Folding
-- -------

-- | Left fold
foldl :: Unbox b => (a -> b -> a) -> a -> Vector b -> a
{-# INLINE foldl #-}
foldl = G.foldl

-- | Lefgt fold on non-empty vectors
foldl1 :: Unbox a => (a -> a -> a) -> Vector a -> a
{-# INLINE foldl1 #-}
foldl1 = G.foldl1

-- | Left fold with strict accumulator
foldl' :: Unbox b => (a -> b -> a) -> a -> Vector b -> a
{-# INLINE foldl' #-}
foldl' = G.foldl'

-- | Left fold on non-empty vectors with strict accumulator
foldl1' :: Unbox a => (a -> a -> a) -> Vector a -> a
{-# INLINE foldl1' #-}
foldl1' = G.foldl1'

-- | Right fold
foldr :: Unbox a => (a -> b -> b) -> b -> Vector a -> b
{-# INLINE foldr #-}
foldr = G.foldr

-- | Right fold on non-empty vectors
foldr1 :: Unbox a => (a -> a -> a) -> Vector a -> a
{-# INLINE foldr1 #-}
foldr1 = G.foldr1

-- Specialised folds
-- -----------------

sum :: (Unbox a, Num a) => Vector a -> a
{-# INLINE sum #-}
sum = G.sum

product :: (Unbox a, Num a) => Vector a -> a
{-# INLINE product #-}
product = G.product

maximum :: (Unbox a, Ord a) => Vector a -> a
{-# INLINE maximum #-}
maximum = G.maximum

minimum :: (Unbox a, Ord a) => Vector a -> a
{-# INLINE minimum #-}
minimum = G.minimum

-- Unfolding
-- ---------

unfoldr :: Unbox a => (b -> Maybe (a, b)) -> b -> Vector a
{-# INLINE unfoldr #-}
unfoldr = G.unfoldr

-- Scans
-- -----

-- | Prefix scan
prescanl :: (Unbox a, Unbox b) => (a -> b -> a) -> a -> Vector b -> Vector a
{-# INLINE prescanl #-}
prescanl = G.prescanl

-- | Prefix scan with strict accumulator
prescanl' :: (Unbox a, Unbox b) => (a -> b -> a) -> a -> Vector b -> Vector a
{-# INLINE prescanl' #-}
prescanl' = G.prescanl'

-- | Suffix scan
postscanl :: (Unbox a, Unbox b) => (a -> b -> a) -> a -> Vector b -> Vector a
{-# INLINE postscanl #-}
postscanl = G.postscanl

-- | Suffix scan with strict accumulator
postscanl' :: (Unbox a, Unbox b) => (a -> b -> a) -> a -> Vector b -> Vector a
{-# INLINE postscanl' #-}
postscanl' = G.postscanl'

-- | Haskell-style scan
scanl :: (Unbox a, Unbox b) => (a -> b -> a) -> a -> Vector b -> Vector a
{-# INLINE scanl #-}
scanl = G.scanl

-- | Haskell-style scan with strict accumulator
scanl' :: (Unbox a, Unbox b) => (a -> b -> a) -> a -> Vector b -> Vector a
{-# INLINE scanl' #-}
scanl' = G.scanl'

-- | Scan over a non-empty 'Vector'
scanl1 :: Unbox a => (a -> a -> a) -> Vector a -> Vector a
{-# INLINE scanl1 #-}
scanl1 = G.scanl1

-- | Scan over a non-empty 'Vector' with a strict accumulator
scanl1' :: Unbox a => (a -> a -> a) -> Vector a -> Vector a
{-# INLINE scanl1' #-}
scanl1' = G.scanl1'

-- Enumeration
-- -----------

enumFromTo :: (Unbox a, Enum a) => a -> a -> Vector a
{-# INLINE enumFromTo #-}
enumFromTo = G.enumFromTo

enumFromThenTo :: (Unbox a, Enum a) => a -> a -> a -> Vector a
{-# INLINE enumFromThenTo #-}
enumFromThenTo = G.enumFromThenTo

-- Conversion to/from lists
-- ------------------------

-- | Convert a vector to a list
toList :: Unbox a => Vector a -> [a]
{-# INLINE toList #-}
toList = G.toList

-- | Convert a list to a vector
fromList :: Unbox a => [a] -> Vector a
{-# INLINE fromList #-}
fromList = G.fromList

#define DEFINE_IMMUTABLE
#include "unbox-tuple-instances"

