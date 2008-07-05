{-# LANGUAGE ExistentialQuantification, BangPatterns #-}

module Data.Vector.Stream (
  Step(..), Stream(..),

  empty, singleton, replicate,
  map, filter, zipWith,
  foldr, foldl, foldl',
  mapM_, foldM
) where

import Prelude hiding ( replicate, map, filter, zipWith,
                        foldr, foldl,
                        mapM_ )

data Step s a = Yield a s
              | Skip    s
              | Done

data Stream a = forall s. Stream (s -> Step s a) s Int

empty :: Stream a
{-# INLINE_STREAM empty #-}
empty = Stream (const Done) () 0

singleton :: a -> Stream a
{-# INLINE_STREAM singleton #-}
singleton x = Stream step True 1
  where
    {-# INLINE step #-}
    step True  = Yield x False
    step False = Done

replicate :: Int -> a -> Stream a
{-# INLINE_STREAM replicate #-}
replicate n x = Stream step n (max n 0)
  where
    {-# INLINE step #-}
    step i | i > 0     = Yield x (i-1)
           | otherwise = Done

map :: (a -> b) -> Stream a -> Stream b
{-# INLINE_STREAM map #-}
map f (Stream step s n) = Stream step' s n
  where
    {-# INLINE step' #-}
    step' s = case step s of
                Yield x s' -> Yield (f x) s'
                Skip    s' -> Skip        s'
                Done       -> Done

filter :: (a -> Bool) -> Stream a -> Stream a
{-# INLINE_STREAM filter #-}
filter f (Stream step s n) = Stream step' s n
  where
    {-# INLINE step' #-}
    step' s = case step s of
                Yield x s' | f x       -> Yield x s'
                           | otherwise -> Skip    s'
                Skip    s'             -> Skip    s'
                Done                   -> Done

zipWith :: (a -> b -> c) -> Stream a -> Stream b -> Stream c
{-# INLINE_STREAM zipWith #-}
zipWith f (Stream stepa sa na) (Stream stepb sb nb)
  = Stream step (sa, sb, Nothing) (min na nb)
  where
    {-# INLINE step #-}
    step (sa, sb, Nothing) = case stepa sa of
                               Yield x sa' -> Skip (sa', sb, Just x)
                               Skip    sa' -> Skip (sa', sb, Nothing)
                               Done        -> Done

    step (sa, sb, Just x)  = case stepb sb of
                               Yield y sb' -> Yield (f x y) (sa, sb', Nothing)
                               Skip    sb' -> Skip          (sa, sb', Just x)
                               Done        -> Done

foldl :: (a -> b -> b) -> b -> Stream a -> b
{-# INLINE_STREAM foldl #-}
foldl f z (Stream step s _) = foldl_go z s
  where
    foldl_go z s = case step s of
                     Yield x s' -> foldl_go (f x z) s'
                     Skip    s' -> foldl_go z       s'
                     Done       -> z

foldl' :: (a -> b -> b) -> b -> Stream a -> b
{-# INLINE_STREAM foldl' #-}
foldl' f z (Stream step s _) = foldl_go z s
  where
    foldl_go !z s = case step s of
                      Yield x s' -> foldl_go (f x z) s'
                      Skip    s' -> foldl_go z       s'
                      Done       -> z

foldr :: (a -> b -> b) -> b -> Stream a -> b
{-# INLINE_STREAM foldr #-}
foldr f z (Stream step s _) = foldr_go s
  where
    foldr_go s = case step s of
                   Yield x s' -> f x (foldr_go s')
                   Skip    s' -> foldr_go s'
                   Done       -> z

mapM_ :: Monad m => (a -> m ()) -> Stream a -> m ()
{-# INLINE_STREAM mapM_ #-}
mapM_ m (Stream step s _) = mapM_go s
   where
     mapM_go s = case step s of
                   Yield x s' -> do { m x; mapM_go s' }
                   Skip    s' -> mapM_go s'
                   Done       -> return ()

foldM :: Monad m => (a -> b -> m a) -> a -> Stream b -> m a
{-# INLINE_STREAM foldM #-}
foldM m z (Stream step s _) = foldM_go z s
  where
    foldM_go z s = case step s of
                     Yield x s' -> do { z' <- m z x; foldM_go z' s' }
                     Skip    s' -> foldM_go z s'
                     Done       -> return z

