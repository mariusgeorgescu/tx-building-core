{-# LANGUAGE FunctionalDependencies #-}

module TxBuilding.MonadInteraction where

import Control.Monad.IO.Class
import GeniusYield.TxBuilder
import GeniusYield.Types
import Text.Printf
import TxBuilding.Context
import TxBuilding.Types

------------------------------------------------------------------------------------------------

-- * MonadInteraction class

------------------------------------------------------------------------------------------------

class (MonadIO m) => MonadInteraction actionType txBuildingContext m | m -> actionType txBuildingContext where
  getProviderCtx :: m ProviderCtx
  getTxBuildingContext :: m txBuildingContext
  mkInteractionSkeleton ::
    (GYTxUserQueryMonad n) =>
    Interaction actionType -> txBuildingContext -> m (n (GYTxSkeleton 'PlutusV3))

  -------
  -- with default implementation
  ------
  mkInteractionTxBody :: Interaction actionType -> m GYTxBody
  mkInteractionTxBody i@Interaction {..} = do
    txBuildingContext <- getTxBuildingContext
    providerCtx <- getProviderCtx
    builderMonadSkeleton <- mkInteractionSkeleton i txBuildingContext
    liftIO $
      runTx
        providerCtx
        (usedAddresses userAddresses)
        (changeAddress userAddresses)
        (reservedCollateral userAddresses)
        builderMonadSkeleton

  mkInteractionUnsignedTx :: Interaction actionType -> m GYTx
  mkInteractionUnsignedTx = fmap unsignedTx . mkInteractionTxBody
  mkInteractionHexEncodedCBOR :: Interaction actionType -> m String
  mkInteractionHexEncodedCBOR = (txToHex <$>) . mkInteractionUnsignedTx
  submitTransaction :: GYTx -> m GYTxId
  submitTransaction gyTx = do
    providerCtx <- getProviderCtx
    gyTxId <- liftIO $ gySubmitTx (ctxProviders providerCtx) gyTx
    liftIO $ printf "Submitted transaction: \n\t %s \n" gyTxId
    return gyTxId

  submitTransactionAndWaitForConfirmation :: GYTx -> m GYTxId
  submitTransactionAndWaitForConfirmation gyTx = do
    gyTxId <- submitTransaction gyTx
    providerCtx <- getProviderCtx
    liftIO $ gyAwaitTxConfirmed (ctxProviders providerCtx) (GYAwaitTxParameters 100 10_000_000 1) gyTxId
    liftIO $ printf "Confirmed:  \n\t %s \n" gyTxId
    return gyTxId
