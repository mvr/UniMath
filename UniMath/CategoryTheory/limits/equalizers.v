(**

Direct implementation of equalizers together with:

- Proof that the equalizer arrow is monic ([EqualizerArrowisMonic])

Written by Tomi Pannila

*)
Require Import UniMath.Foundations.Basics.PartD.
Require Import UniMath.Foundations.Basics.Propositions.
Require Import UniMath.Foundations.Basics.Sets.

Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.Monics.

Section def_equalizers.

  Context {C : precategory}.

  (** Definition and construction of isEqualizer. *)
  Definition isEqualizer {x y z : C} (f g : y --> z) (e : x --> y)
             (H : e ;; f = e ;; g) : UU :=
    Π (w : C) (h : w --> y) (H : h ;; f = h ;; g),
      iscontr (Σ φ : w --> x, φ ;; e = h).

  Definition mk_isEqualizer {x y z : C} (f g : y --> z) (e : x --> y)
             (H : e ;; f = e ;; g) :
    (Π (w : C) (h : w --> y) (H' : h ;; f = h ;; g),
        iscontr (Σ ψ : w --> x, ψ ;; e = h)) -> isEqualizer f g e H.
  Proof.
    intros X. unfold isEqualizer. exact X.
  Defined.

  Lemma isaprop_isEqualizer {x y z : C} (f g : y --> z) (e : x --> y)
        (H : e ;; f = e ;; g) :
    isaprop (isEqualizer f g e H).
  Proof.
    repeat (apply impred; intro).
    apply isapropiscontr.
  Defined.

  (** Proves that the arrow to the equalizer object with the right
    commutativity property is unique. *)
  Lemma isEqualizerInUnique {x y z : C} (f g : y --> z) (e : x --> y)
        (H : e ;; f = e ;; g) (E : isEqualizer f g e H)
        (w : C) (h : w --> y) (H' : h ;; f = h ;; g)
        (φ : w --> x) (H'' : φ ;; e = h) :
    φ = (pr1 (pr1 (E w h H'))).
  Proof.
    set (T := tpair (fun ψ : w --> x => ψ ;; e = h) φ H'').
    set (T' := pr2 (E w h H') T).
    apply (base_paths _ _ T').
  Defined.

  (** Definition and construction of equalizers. *)
  Definition Equalizer {y z : C} (f g : y --> z) : UU :=
    Σ e : (Σ w : C, w --> y),
          (Σ H : (pr2 e) ;; f = (pr2 e) ;; g, isEqualizer f g (pr2 e) H).

  Definition mk_Equalizer {x y z : C} (f g : y --> z) (e : x --> y)
             (H : e ;; f = e ;; g) (isE : isEqualizer f g e H) :
    Equalizer f g.
  Proof.
    simple refine (tpair _ _ _).
    - simple refine (tpair _ _ _).
      + apply x.
      + apply e.
    - simpl. refine (tpair _ H isE).
  Defined.

  (** Equalizers in precategories. *)
  Definition Equalizers : UU := Π (y z : C) (f g : y --> z), Equalizer f g.

  Definition hasEqualizers : UU := Π (y z : C) (f g : y --> z),
      ishinh (Equalizer f g).

  (** Returns the equalizer object. *)
  Definition EqualizerObject {y z : C} {f g : y --> z} (E : Equalizer f g) :
    C := pr1 (pr1 E).
  Coercion EqualizerObject : Equalizer >-> ob.

  (** Returns the equalizer arrow. *)
  Definition EqualizerArrow {y z : C} {f g : y --> z} (E : Equalizer f g) :
    C⟦E, y⟧ := pr2 (pr1 E).

  (** The equality on morphisms that equalizers must satisfy. *)
  Definition EqualizerEqAr {y z : C} {f g : y --> z} (E : Equalizer f g) :
    EqualizerArrow E ;; f = EqualizerArrow E ;; g := pr1 (pr2 E).

  (** Returns the property isEqualizer from Equalizer. *)
  Definition isEqualizer_Equalizer {y z : C} {f g : y --> z}
             (E : Equalizer f g) :
    isEqualizer f g (EqualizerArrow E) (EqualizerEqAr E) := pr2 (pr2 E).

  (** Every morphism which satisfy the equalizer equality on morphism factors
    uniquely through the EqualizerArrow. *)
  Definition EqualizerIn {y z : C} {f g : y --> z} (E : Equalizer f g)
             (w : C) (h : w --> y) (H : h ;; f = h ;; g) :
    C⟦w, E⟧ := pr1 (pr1 (isEqualizer_Equalizer E w h H)).

  Lemma EqualizerCommutes {y z : C} {f g : y --> z} (E : Equalizer f g)
        (w : C) (h : w --> y) (H : h ;; f = h ;; g) :
    (EqualizerIn E w h H) ;; (EqualizerArrow E) = h.
  Proof.
    exact (pr2 (pr1 ((isEqualizer_Equalizer E) w h H))).
  Defined.

  Lemma isEqualizerInsEq {x y z: C} {f g : y --> z} {e : x --> y}
        {H : e ;; f = e ;; g} (E : isEqualizer f g e H)
        {w : C} (φ1 φ2: w --> x) (H' : φ1 ;; e = φ2 ;; e) : φ1 = φ2.
  Proof.
    assert (H'1 : φ1 ;; e ;; f = φ1 ;; e ;; g).
    rewrite <- assoc. rewrite H. rewrite assoc. apply idpath.
    set (E' := mk_Equalizer _ _ _ _ E).
    set (E'ar := EqualizerIn E' w (φ1 ;; e) H'1).
    pathvia E'ar.
    apply isEqualizerInUnique. apply idpath.
    apply pathsinv0. apply isEqualizerInUnique. apply pathsinv0. apply H'.
  Defined.

  Lemma EqualizerInsEq {y z: C} {f g : y --> z} (E : Equalizer f g)
        {w : C} (φ1 φ2: C⟦w, E⟧)
        (H' : φ1 ;; (EqualizerArrow E) = φ2 ;; (EqualizerArrow E)) : φ1 = φ2.
  Proof.
    apply (isEqualizerInsEq (isEqualizer_Equalizer E) _ _ H').
  Defined.

  (** Morphisms between equalizer objects with the right commutativity
    equalities. *)
  Definition identity_is_EqualizerIn {y z : C} {f g : y --> z}
             (E : Equalizer f g) :
    Σ φ : C⟦E, E⟧, φ ;; (EqualizerArrow E) = (EqualizerArrow E).
  Proof.
    exists (identity E).
    apply id_left.
  Defined.

  Lemma EqualizerEndo_is_identity {y z : C} {f g : y --> z} {E : Equalizer f g}
        (φ : C⟦E, E⟧) (H : φ ;; (EqualizerArrow E) = EqualizerArrow E) :
    identity E = φ.
  Proof.
    set (H1 := tpair ((fun φ' : C⟦E, E⟧ => φ' ;; _ = _)) φ H).
    assert (H2 : identity_is_EqualizerIn E = H1).
    - apply proofirrelevance.
      apply isapropifcontr.
      apply (isEqualizer_Equalizer E).
      apply EqualizerEqAr.
    - apply (base_paths _ _ H2).
  Defined.

  Definition from_Equalizer_to_Equalizer {y z : C} {f g : y --> z}
             (E E': Equalizer f g) : C⟦E, E'⟧.
  Proof.
    apply (EqualizerIn E' E (EqualizerArrow E)).
    apply EqualizerEqAr.
  Defined.

  Lemma are_inverses_from_Equalizer_to_Equalizer {y z : C} {f g : y --> z}
        {E E': Equalizer f g} :
    is_inverse_in_precat (from_Equalizer_to_Equalizer E E')
                         (from_Equalizer_to_Equalizer E' E).
  Proof.
    split; apply pathsinv0; use EqualizerEndo_is_identity;
    rewrite <- assoc; unfold from_Equalizer_to_Equalizer;
      repeat rewrite EqualizerCommutes; apply idpath.
  Defined.

  Lemma isiso_from_Equalizer_to_Equalizer {y z : C} {f g : y --> z}
        (E E' : Equalizer f g) :
    is_isomorphism (from_Equalizer_to_Equalizer E E').
  Proof.
    apply (is_iso_qinv _ (from_Equalizer_to_Equalizer E' E)).
    apply are_inverses_from_Equalizer_to_Equalizer.
  Defined.

  Definition iso_from_Equalizer_to_Equalizer {y z : C} {f g : y --> z}
             (E E' : Equalizer f g) : iso E E' :=
    tpair _ _ (isiso_from_Equalizer_to_Equalizer E E').


  (** We prove that EqualizerArrow is a monic. *)
  Lemma EqualizerArrowisMonic {y z : C} {f g : y --> z} (E : Equalizer f g ) :
    isMonic (EqualizerArrow E).
  Proof.
    apply mk_isMonic.
    intros z0 g0 h X.
    apply (EqualizerInsEq E).
    apply X.
  Qed.

  Lemma EqualizerArrowMonic {y z : C} {f g : y --> z} (E : Equalizer f g ) :
    Monic _ E y.
  Proof.
    exact (mk_Monic C (EqualizerArrow E) (EqualizerArrowisMonic E)).
  Defined.
End def_equalizers.

(** Make the C not implicit for Equalizers *)
Arguments Equalizers : clear implicits.