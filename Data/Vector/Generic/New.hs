{-# LANGUAGE Rank2Types, FlexibleContexts #-}

-- |
-- Module      : Data.Vector.Generic.New
-- Copyright   : (c) Roman Leshchinskiy 2008-2010
-- License     : BSD-style
--
-- Maintainer  : Roman Leshchinskiy <rl@cse.unsw.edu.au>
-- Stability   : experimental
-- Portability : non-portable
-- 
-- Purely functional interface to initialisation of mutable vectors
--

module Data.Vector.Generic.New (
  New(..), create, run, runPrim, apply, modify, modifyWithStream,
  unstream, transform, unstreamR, transformR,
  slice, init, tail, take, drop,
  unsafeSlice, unsafeInit, unsafeTail
) where

import qualified Data.Vector.Generic.Mutable as MVector
import           Data.Vector.Generic.Mutable ( MVector )

import           Data.Vector.Generic.Base ( Vector, Mutable )

import           Data.Vector.Fusion.Stream ( Facets, MFacets )
import qualified Data.Vector.Fusion.Stream as Stream

import Control.Monad.Primitive
import Control.Monad.ST ( ST )
import Control.Monad  ( liftM )
import Prelude hiding ( init, tail, take, drop, reverse, map, filter )

#include "vector.h"

data New v a = New (forall s. ST s (Mutable v s a))

create :: (forall s. ST s (Mutable v s a)) -> New v a
{-# INLINE create #-}
create p = New p

run :: New v a -> ST s (Mutable v s a)
{-# INLINE run #-}
run (New p) = p

runPrim :: PrimMonad m => New v a -> m (Mutable v (PrimState m) a)
{-# INLINE runPrim #-}
runPrim (New p) = primToPrim p

apply :: (forall s. Mutable v s a -> Mutable v s a) -> New v a -> New v a
{-# INLINE apply #-}
apply f (New p) = New (liftM f p)

modify :: (forall s. Mutable v s a -> ST s ()) -> New v a -> New v a
{-# INLINE modify #-}
modify f (New p) = New (do { v <- p; f v; return v })

modifyWithStream :: (forall s. Mutable v s a -> Facets u b -> ST s ())
                 -> New v a -> Facets u b -> New v a
{-# INLINE_STREAM modifyWithStream #-}
modifyWithStream f (New p) s = s `seq` New (do { v <- p; f v s; return v })

unstream :: Vector v a => Facets v a -> New v a
{-# INLINE_STREAM unstream #-}
unstream s = s `seq` New (MVector.vunstream s)

transform :: Vector v a =>
        (forall m. Monad m => MFacets m u a -> MFacets m u a) -> New v a -> New v a
{-# INLINE_STREAM transform #-}
transform f (New p) = New (MVector.transform f =<< p)

{-# RULES

"transform/transform [New]"
  forall (f :: forall m. Monad m => MFacets m v a -> MFacets m v a)
         (g :: forall m. Monad m => MFacets m v a -> MFacets m v a)
         p .
  transform f (transform g p) = transform (f . g) p

"transform/unstream [New]"
  forall (f :: forall m. Monad m => MFacets m v a -> MFacets m v a)
         s.
  transform f (unstream s) = unstream (f s)

 #-}


unstreamR :: Vector v a => Facets v a -> New v a
{-# INLINE_STREAM unstreamR #-}
unstreamR s = s `seq` New (MVector.unstreamR s)

transformR :: Vector v a =>
        (forall m. Monad m => MFacets m u a -> MFacets m u a) -> New v a -> New v a
{-# INLINE_STREAM transformR #-}
transformR f (New p) = New (MVector.transformR f =<< p)

{-# RULES

"transformR/transformR [New]"
  forall (f :: forall m. Monad m => MFacets m v a -> MFacets m v a)
         (g :: forall m. Monad m => MFacets m v a -> MFacets m v a)
         p .
  transformR f (transformR g p) = transformR (f . g) p

"transformR/unstreamR [New]"
  forall (f :: forall m. Monad m => MFacets m v a -> MFacets m v a)
         s.
  transformR f (unstreamR s) = unstreamR (f s)

 #-}

slice :: Vector v a => Int -> Int -> New v a -> New v a
{-# INLINE_STREAM slice #-}
slice i n m = apply (MVector.slice i n) m

init :: Vector v a => New v a -> New v a
{-# INLINE_STREAM init #-}
init m = apply MVector.init m

tail :: Vector v a => New v a -> New v a
{-# INLINE_STREAM tail #-}
tail m = apply MVector.tail m

take :: Vector v a => Int -> New v a -> New v a
{-# INLINE_STREAM take #-}
take n m = apply (MVector.take n) m

drop :: Vector v a => Int -> New v a -> New v a
{-# INLINE_STREAM drop #-}
drop n m = apply (MVector.drop n) m

unsafeSlice :: Vector v a => Int -> Int -> New v a -> New v a
{-# INLINE_STREAM unsafeSlice #-}
unsafeSlice i n m = apply (MVector.unsafeSlice i n) m

unsafeInit :: Vector v a => New v a -> New v a
{-# INLINE_STREAM unsafeInit #-}
unsafeInit m = apply MVector.unsafeInit m

unsafeTail :: Vector v a => New v a -> New v a
{-# INLINE_STREAM unsafeTail #-}
unsafeTail m = apply MVector.unsafeTail m

{-# RULES

"slice/unstream [New]" forall i n s.
  slice i n (unstream s) = unstream (Stream.slice i n s)

"init/unstream [New]" forall s.
  init (unstream s) = unstream (Stream.init s)

"tail/unstream [New]" forall s.
  tail (unstream s) = unstream (Stream.tail s)

"take/unstream [New]" forall n s.
  take n (unstream s) = unstream (Stream.take n s)

"drop/unstream [New]" forall n s.
  drop n (unstream s) = unstream (Stream.drop n s)

"unsafeSlice/unstream [New]" forall i n s.
  unsafeSlice i n (unstream s) = unstream (Stream.slice i n s)

"unsafeInit/unstream [New]" forall s.
  unsafeInit (unstream s) = unstream (Stream.init s)

"unsafeTail/unstream [New]" forall s.
  unsafeTail (unstream s) = unstream (Stream.tail s)

  #-}

