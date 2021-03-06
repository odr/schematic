module Data.Schematic.Verifier.Number where

import Data.Schematic.Compat
import Data.Schematic.Constraints
import Data.Schematic.Verifier.Common


toStrictNumber :: [NumberConstraintT] -> [NumberConstraintT]
toStrictNumber = map f
  where
    f (NLe x) = NLt (x + 1)
    f (NGe x) = NGt (x - 1)
    f x       = x

data VerifiedNumberConstraint
  = VNEq DeNat
  | VNBounds (Maybe DeNat) (Maybe DeNat)
  deriving (Show)

verifyNumberConstraints
  :: [NumberConstraintT]
  -> Maybe VerifiedNumberConstraint
verifyNumberConstraints cs' = do
  let
    cs = toStrictNumber cs'
    mlt = simplifyNLs [x | NLt x <- cs]
    mgt = simplifyNGs [x | NGt x <- cs]
  meq <- verifyNEq [x | NEq x <- cs]
  verifyEquations mgt meq mlt
  Just $
    case meq of
      Just eq -> VNEq eq
      Nothing -> VNBounds mgt mlt
