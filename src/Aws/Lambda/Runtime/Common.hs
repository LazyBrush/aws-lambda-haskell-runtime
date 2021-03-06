{-# LANGUAGE DeriveLift #-}

module Aws.Lambda.Runtime.Common
  ( RunCallback
  , LambdaResult(..)
  , LambdaError(..)
  , LambdaOptions(..)
  , DispatcherOptions(..)
  , ApiGatewayDispatcherOptions(..)
  , DispatcherStrategy(..)
  , defaultDispatcherOptions
  ) where

import Aws.Lambda.Runtime.ApiGatewayInfo
import Data.Aeson (Value)
import GHC.Generics (Generic)
import Language.Haskell.TH.Syntax (Lift)

-- | API Gateway specific dispatcher options
newtype ApiGatewayDispatcherOptions = ApiGatewayDispatcherOptions
  { propagateImpureExceptions :: Bool
  -- ^ Should impure exceptions be propagated through the API Gateway interface
  } deriving (Lift)

-- | Options that the dispatcher generator expects
newtype DispatcherOptions = DispatcherOptions
  { apiGatewayDispatcherOptions :: ApiGatewayDispatcherOptions
  } deriving (Lift)

defaultDispatcherOptions :: DispatcherOptions
defaultDispatcherOptions =
  DispatcherOptions (ApiGatewayDispatcherOptions True)

-- | A strategy on how to generate the dispatcher functions
data DispatcherStrategy =
  UseWithAPIGateway |
  StandaloneLambda
  deriving (Lift)

-- | Callback that we pass to the dispatcher function
type RunCallback =
  LambdaOptions -> IO (Either LambdaError LambdaResult)

-- | Wrapper type for lambda execution results
data LambdaError =
  StandaloneLambdaError String |
  ApiGatewayLambdaError (ApiGatewayResponse Value)

-- | Wrapper type to handle the result of the user
data LambdaResult =
  StandaloneLambdaResult String |
  ApiGatewayResult (ApiGatewayResponse Value)

-- | Options that the generated main expects
data LambdaOptions = LambdaOptions
  { eventObject     :: !String
  , contextObject   :: !String
  , functionHandler :: !String
  , executionUuid   :: !String
  } deriving (Generic)