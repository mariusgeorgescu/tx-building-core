{-# OPTIONS_GHC -Wno-orphans #-}

module TxBuilding.Instances where

import Control.Monad.IO.Class
import GeniusYield.TxBuilder
import GeniusYield.TxBuilder.IO.Unsafe (unsafeIOToQueryMonad, unsafeIOToTxBuilderMonad)

instance MonadIO GYTxQueryMonadIO where
  liftIO :: IO a -> GYTxQueryMonadIO a
  liftIO = unsafeIOToQueryMonad

instance MonadIO GYTxBuilderMonadIO where
  liftIO :: IO a -> GYTxBuilderMonadIO a
  liftIO = unsafeIOToTxBuilderMonad
