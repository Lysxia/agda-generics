{-# OPTIONS --safe --without-K #-}

module Generics.HasDesc.Simple where

open import Agda.Primitive
open import Agda.Builtin.Nat renaming (Nat to ℕ)
open import Agda.Builtin.Sigma
open import Agda.Builtin.Equality
open import Data.Fin.Base
open import Data.Vec.Base
open import Function.Base

open import Generics.Desc.Simple

private
  variable
    ℓ : Level

module _ {ℓ} {I : Set ℓ} (A : I → Set ℓ) where

  Constr : ConDesc I → Set ℓ
  Constr (κ γ  ) = A γ
  Constr (ι γ C) = A γ     → Constr C
  Constr (σ S C) = (s : S) → Constr (C s)

  Constr-proof : ∀ {n} {D : Desc I n}
                 (to   : ∀ {γ} → A γ → μ D γ)
                 (from : ∀ {γ} → μ D γ → A γ)
                 {k} → Constr (lookup D k) → Set ℓ
  Constr-proof {n} {D} to from {k} = aux (lookup D k) λ x′ x → x ≡ from ⟨ k , x′ ⟩
    where
      aux : ∀ C (tie : {γ : I} → ⟦ C ⟧C (μ D) γ → A γ → Set ℓ)
          → Constr C → Set ℓ
      aux (κ γ  ) tie constr = tie refl constr
      aux (ι γ C) tie constr = (x : A γ) → aux C (tie ∘ (to x ,_)) (constr x)
      aux (σ S C) tie constr = (s : S  ) → aux (C s) (tie ∘ (s ,_)) (constr s)


record HasDesc {I : Set ℓ} (A : I → Set ℓ) : Set (lsuc ℓ) where
  field
    {n} : ℕ
    D   : Desc I n

    to   : ∀ {i} → A i → μ D i
    from : ∀ {i} → μ D i → A i

    to∘from : ∀ {i} (x : μ D i) → to (from x) ≡ x
    from∘to : ∀ {i} (x : A i  ) → from (to x) ≡ x

  field
    -- constructors of A
    constr : ∀ k → Constr A (lookup D k)

    -- proof that constr indeed holds the constructors of A
    constr-proof : ∀ k → Constr-proof A to from (constr k)
