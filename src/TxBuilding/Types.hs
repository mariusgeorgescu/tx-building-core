module TxBuilding.Types where

import Data.Aeson
import Data.Aeson.Types
import Data.List.Extra (dropPrefix)
import Data.Swagger (ToSchema (..), genericDeclareNamedSchema)
import Data.Swagger.Schema (SchemaOptions, defaultSchemaOptions, fromAesonOptions)
import Deriving.Aeson
import GeniusYield.GYConfig
import GeniusYield.Types

------------------------------------------------------------------------------------------------

-- * Types

------------------------------------------------------------------------------------------------
data ProviderCtx = ProviderCtx
  { ctxCoreCfg :: !GYCoreConfig,
    ctxProviders :: !GYProviders
  }

-- | Input parameters to add for reference script.
data AddWitAndSubmitParams = AddWitAndSubmitParams
  { awasTxUnsigned :: !GYTx,
    awasTxWit :: !GYTxWitness
  }
  deriving (Generic)
  deriving (FromJSON) via CustomJSON '[FieldLabelModifier '[StripPrefix "awas", CamelToSnake]] AddWitAndSubmitParams

instance ToSchema AddWitAndSubmitParams where
  declareNamedSchema = genericDeclareNamedSchema addWitAndSubmitParamsSchemaOptions
    where
      addWitAndSubmitParamsSchemaOptions :: SchemaOptions
      addWitAndSubmitParamsSchemaOptions =
        fromAesonOptions $
          Data.Aeson.Types.defaultOptions
            { Data.Aeson.Types.fieldLabelModifier = camelTo2 '_' . dropPrefix "awas"
            }

data UserAddresses = UserAddresses
  { -- | User's used addresses.
    usedAddresses :: [GYAddress],
    -- | User's change address.
    changeAddress :: GYAddress,
    -- | Browser wallet's reserved collateral (if set).
    reservedCollateral :: Maybe GYTxOutRefCbor,
    -- |  User's stake address.
    stakeAddresses :: [GYStakeAddress]
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

data ActionType = DelegateToPool | DelegateToDRep | DelegateToPoolAndDRep
  deriving (Show, Generic)
  deriving (FromJSON, ToJSON, ToSchema)

data Interaction a
  = Interaction
  { -- | The intented action to perfrom.
    action :: a,
    -- | The user addresses to be used as input for transaction building.
    userAddresses :: UserAddresses
  }
  deriving (Show, Generic, FromJSON, ToJSON)

instance (ToSchema a) => ToSchema (Interaction a) where
  declareNamedSchema = genericDeclareNamedSchema defaultSchemaOptions
