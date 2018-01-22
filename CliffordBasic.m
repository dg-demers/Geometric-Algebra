(* ::Package:: *)

(* Set up the Package Context. *)

(* :Title: ClifordBasic.m -- Basic Clifford Algebra Calculator *)

(* :Author: Jose L. Aragon *)

(* :Summary:
       This file contains declarations for basic calculations with Clifford
       algebra of a n-dimensional vector space with signature {p,q} 
       generated by  {e[1], e[2],....,e[n]} and relations
       
                   e[i]^2 = e[i,i] =  1      1 < i <= p
                   e[i]^2 = e[i,j] = -1      p < i <= n
                   e[i,j] = -e[j,i]
       
       The geometric product of basis elements are denoted as 
       e[2,3,1] (=e_2 e_3 e_1), etc.
       
       The result of any calculation is given in terms of the geometric product
       of basis elements, that is, the outer (Grassman) product of basis
       elements or multivectors is calculated by using OuterProduct[] and the
       output is given in terms of geometric product of basis vectors.
            
       Examples:     The vector {1,2,0,-1} is written as
                     e[1] + 2 e[2] - e[4].
                     
                     The multivector a + 5e1 + e1e2e3 is written as
                     a + 5 e[1] + e[1,2,3].
   
       With the exception of the function Dual[m,n], it is not
       neccesary to define the dimension of the vector space, it
       is calculated automatically by the function dimensions[ ].
       
       The signature of the bilinear form is set by 
       $SetSignature, if not specified, the 
       default value is 
       
       $SetSignature = {20,0}
*)

(* :Copyright: (c) 2017 by Jose L. Aragon *)

(* :Package Version: 1.0 *)

(* :Mathematica Version: 11.0 *)
	   
(* :History:
    This is a completely renewed but reduced version of 
    Clifford.m package by G. Aragon-Camarasa, G. Aragon-Gonzalez, 
    J.L. Aragon and M.A. Rodriguez-Andrade.
    
    Using rule-base programming the algebra is constructed as 
    proposed by Alan Macdonald in "An Elementary Construction
    of Geometric Algebra". 

	First version: November 2107
 *)

(* :References: 
	1. A. Macdonald, "An Elementary Construction of Geometric Algebra",
	   Adv. Appl. Cliff. Alg. 12 (2002) 1-6.  
	2. D. Hestenes. New Foundations for Classical Mechanics. 
	   D. Reidel Publishing Co. Holland (1987)  
	3. D. Hestenes and G. Sobczyk. Clifford Algebra to Geometric Calculus.
	   D. Reidel Publishing Co. Holland (1984)
	4. L. Dorst, D. Fontijne, S. Mann. Geometric Algebra for Computer Science: 
	   An Object-Oriented Approach to Geometry.
	   Morgan Kaufmann Publishers (2007) 
*)
	   
(* :Discussion:
    About InnerProduct, Meet and Joint.
    
    1. InnerProduct[] was implemented according to Hestenes & Sobczyk definition.
       If A is a j-vector and B is a k-vector, then
    
       A.B = <A B>_|k-j|
    
       If A or B are scalars, then A.B=0.
       
       In addition, Left and Right contractions were also implemented,
       as LeftContraction[] and RightContraction[].
    
    2. Meet[] was implemented according Hestenes & Sobczyk definition.
       If A and B are blades in G^n, then
    
       A U B = (-1)^(n(n-1)/2)  (A~ ^ B~)

       where ~ stands for the Dual. See Hestenes & Sobczyk Eq. 2.28.
       Meet and Join are defined up to a scale factor. To set a scale,
       Meet is normalized.
    
    3. Joint[] (Join is a reserved word so can not be used) was implemented
       in terms of the Meet:
       
       A n B = A ^ ( ((A U B)^{-1}) . B )
       
       See Dorst et al. Eq. (5.5). Sined Join is defined in terms of the Meet
       and Meet was normalzed, then a scale for Join is defined.
*)

BeginPackage["CliffordBasic`"]


(* Usage message for the exported function and the Context itself *)

Clifford::usage = "Clifford.m is a package to resolve operations with
Clifford Algebra."

e::usage = "e is used to denote the elements of the standard basis of Euclidean vector
space where the Clifford Algebra is defined, so e[i] is used as i-th basis
element"

GeometricProduct::usage = "GeometricProduct[m1,m2,...] calculates the Geometric
Product of multivectors m1,m2,..."

Coeff::usage = "Coeff[m,b] gives the coefficient of the r-vector b in the multivector m."

Grade::usage = "Grade[m,r] gives the r-vector part of the multivector m."

HomogeneousQ::usage = "HomogeneousQ[x,r] returns True if x is a r-vector and False
otherwise."

GFactor::usage = "GFactor[m] groups terms with commom e[__]."

Pseudoscalar::usage = "Pseudoscalar[n] gives the n-dimensional pseudoscalar."

Turn::usage = "Turn[m] gives the Reversion (~) of the multivector m."

Involution::usage = "Involution[m] gives the involution (^) of the multivector m: 
reverses the sign of odd blades; if m is homogeneous of grade r, then
Involution[m] = (-1)^r m."

Magnitude::usage = "Magnitude[m] calculates the Magnitude of the multivector m."

InnerProduct::usage = "InnerProduct[m1,m2] calculates the Inner Product between
multivectors m1 and m2"

LeftContraction::usage = "LeftContraction[m1,m2] calculates the Left Contraction between
multivectors m1 and m2"

RightContraction::usage = "RightContraction[m1,m2] calculates the Right Contraction between
multivectors m1 and m2"

ScalarProduct::usage = "ScalarProduct[m1,m2] returns the Scalar Product (zero degree terms) of
multivectors m1 and m2"

OuterProduct::usage = "OuterProduct[m1,m2,...] calculates the Outer Product of
multivectors m1,m2,..."

MultivectorInverse::usage = "MultivectorInverse[m] gives the inverse of a
multivector m."

Dual::usage = "Dual[m,n] calculates the Dual of the multivector m in a
n-dimensional space."

Meet::usage = "Meet[m1,m2,n] returns the (normalized) Meet of the multivectors m1 and m2
in a n-dimensional space."

Joint::usage = "Joint[m1,m2,n] returns the Join of the multivectors m1 and m2
in a n-dimensional space."

ToBasis::usage = "ToBasis[x] Transform the vector x from {a,b,...} to the
standar form used in this Package: a e[1] + b e[2]+...."

ToVector::usage ="ToVector[x,n] transform the n-dimensional vector x from
a e[1] + b e[2] +... to the standar Mathematica form {a,b,...}. The defaul 
value of n is 3."

$SetSignature::usage = "$SetSignature sets the indices (p,q) of the bilinear form
used to define the Clifford Algebra. The default value is {20,0}. Once changed, 
it can be recovered by Clear[$SetSignature];."

(* Set the indices (p,q,s) of the bilinear form *)
$SetSignature = {20,0}


Begin["`Private`"]  (* Begin the Private Context *)

(* Unprotect functions *)

(* Error Messages *)

(* Definition of auxiliary functions and local (static) variables *)

(* GFactor groups terms with commom e[__] *)
GFactor[x_] := Collect[Expand[x], e[__]]

(* dimensions returns the maximum dimension of the space where multivector
is embedded *)
dimensions[a_] := 0 /; FreeQ[a, e[__?Positive]]
dimensions[(a_: 1) e[k__?Positive]] := Max[{k}]
dimensions[x_ + y_] := Max[dimensions[x], dimensions[y]]

(* Pseudoscalar function *)
Pseudoscalar[n_ /; Element[n, Integers] && n > 0] := e @@ Range[n]

(* HomogeneousQ function *)
HomogeneousQ[x_,r_ /; Element[r, Integers] && Positive[r]] := Simplify[x === Grade[x,r]]


(* The RELATIONS of the clifford algebra *)
e[] := 1
e[i_Integer, j__Integer] := e[]                                   /; i == j && i <= $SetSignature[[1]] && EvenQ[Length[{i, j}]] && i > 0
e[i_Integer, j__Integer] := e[i]                                  /; i == j && i <= $SetSignature[[1]] && OddQ[Length[{i, j}]] && i > 0
e[i_Integer, j__Integer] := (-e[])^(Length[{i, j}]/2)             /; i == j && i > $SetSignature[[1]] && i <= Plus@@$SetSignature && EvenQ[Length[{i, j}]] && i > 0
e[i_Integer, j__Integer] := (-e[])^((Length[{i, j}] - 1)/2) e[i]  /; i == j && i > $SetSignature[[1]] && i <= Plus@@$SetSignature && OddQ[Length[{i, j}]] && i > 0
e[i_Integer, j__Integer] := 0                                     /; i == j && Max[{i, j}] > Plus@@$SetSignature && AllTrue[{i, j}, Positive]
e[i_Integer, j_Integer] := -e[j,i]                                /; i != j && i > j  && AllTrue[{i, j}, Positive]
e[i__Integer] := Signature[Ordering[{i}]] Apply[e,Sort[{i}]]      /; ! OrderedQ[{i}] && AllTrue[{i}, Positive]
e[i__Integer] := Module[{es = Cases[Apply[e, Gather[{i}], 1], Except[_Integer]]},
                          Return[(Times @@ Join[Cases[Apply[e, Gather[{i}], 1], _Integer], Cases[{Times @@ es}, _Integer]]) e @@ Cases[es, e[x_] :> x]]
                       ]                                          /;  OrderedQ[{i}] && ! DuplicateFreeQ[{i}]  && AllTrue[{i}, Positive]

(* Begin Geometric Product Section *)
GeometricProduct[ _] := $Failed
GeometricProduct[x_, y_] := GeometricProduct[Expand[x], Expand[y]]   /;  x =!= Expand[x] || y =!= Expand[y]
GeometricProduct[x_, y_, z__] := Fold[GeometricProduct, Expand[x], {Expand[y], z}] // Simplify
GeometricProduct[x_, y_ + z_] := GeometricProduct[x, y] + GeometricProduct[x, z]
GeometricProduct[x_ + y_, z_] := GeometricProduct[x, z] + GeometricProduct[y, z]
GeometricProduct[a_, b_] := a b e[]    /; FreeQ[a, e[__]] && FreeQ[b, e[__]]
GeometricProduct[a_ , (b_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]]] := a b e[i]         /; FreeQ[a, e[__]] && FreeQ[b, e[__]]
GeometricProduct[(a_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], b_] :=  a b e[i]         /; FreeQ[a, e[__]] && FreeQ[b, e[__]] 
GeometricProduct[(a_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], (b_: 1) e[j__ /; SubsetQ[Range[Plus @@ $SetSignature],{j}]]] := 
              a b e[i, j]   /; FreeQ[a, e[__]] && FreeQ[b, e[__]]
(* End of Geometric Product Section *)
 
 
(* Begin Grade Section *)
Grade[a_, r_ /; Element[r, Integers]] := If[r === 0, a, 0]             /; FreeQ[a, e[__]]
Grade[x_, r_ /; Element[r, Integers]] := Grade[Expand[x], r]           /; x =!= Expand[x]
Grade[x_, r_ /; Element[r, Integers]] := 0                             /; r < 0
Grade[x_ + y_, r_ /; Element[r, Integers]] := Grade[x, r] + Grade[y, r]
Grade[(a_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], r_ /; Element[r, Integers]] := If[Length[{i}] === r, a e[i], 0]
(* End of Grade Section *)


(* Begin Inner Product Section (a la Hestenes) *)  
InnerProduct[_] := $Failed
InnerProduct[x_, y_] := InnerProduct[Expand[x], Expand[y]]                                      /;  x =!= Expand[x] || y =!= Expand[y]
InnerProduct[x_, y_ + z_] := InnerProduct[x, y] + InnerProduct[x, z]
InnerProduct[x_ + y_, z_] := InnerProduct[x, z] + InnerProduct[y, z]
InnerProduct[a_, b_] := 0                                                                       /; FreeQ[a, e[__]] && FreeQ[b, e[__]]
InnerProduct[a_, (b_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]]] := 0              /; FreeQ[a, e[__]]
InnerProduct[(b_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], a_] := 0              /; FreeQ[a, e[__]]
InnerProduct[(a_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], (b_: 1) e[j__ /; SubsetQ[Range[Plus @@ $SetSignature],{j}]]] := 
              Grade[a b e[i,j], Abs[Length[{i}] - Length[{j}]]]        /; FreeQ[a, e[__]] && FreeQ[b, e[__]] 
(* End of Inner Product Section *)


(* Begin Left Contraction Section (a la Dorst (see Macdonald Eq. 6.5) *)
LeftContraction[_] := $Failed
LeftContraction[x_, y_] := LeftContraction[Expand[x], Expand[y]]                                 /;  x =!= Expand[x] || y =!= Expand[y]
LeftContraction[x_, y_ + z_] := LeftContraction[x, y] + LeftContraction[x, z]
LeftContraction[x_ + y_, z_] := LeftContraction[x, z] + LeftContraction[y, z]
LeftContraction[a_, b_] := a b                                                                   /; FreeQ[a, e[__]] && FreeQ[b, e[__]]
LeftContraction[a_, (b_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]]] := a b e[i]     /; FreeQ[a, e[__]]
LeftContraction[(b_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], a_] := 0            /; FreeQ[a, e[__]]
LeftContraction[(a_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], (b_: 1) e[j__ /; SubsetQ[Range[Plus @@ $SetSignature],{j}]]] := 
              a b Grade[e[i,j], Length[{j}] - Length[{i}]]        /; FreeQ[a, e[__]] && FreeQ[b, e[__]]
(* End of Left Contraction Section *)


(* Begin Right Contraction Section (a la Dorst (see Macdonald Eq. 6.5) *)
RightContraction[_] := $Failed
RightContraction[x_, y_] := RightContraction[Expand[x], Expand[y]]                                /;  x =!= Expand[x] || y =!= Expand[y]
RightContraction[x_, y_ + z_] := RightContraction[x, y] + RightContraction[x, z]
RightContraction[x_ + y_, z_] := RightContraction[x, z] + RightContraction[y, z]
RightContraction[a_, b_] := a b                                                                   /; FreeQ[a, e[__]] && FreeQ[b, e[__]]
RightContraction[a_, (b_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]]] := 0            /; FreeQ[a, e[__]]
RightContraction[(b_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], a_] := a b e[i]     /; FreeQ[a, e[__]]
RightContraction[(a_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], (b_: 1) e[j__ /; SubsetQ[Range[Plus @@ $SetSignature],{j}]]] := 
              a b Grade[e[i,j], Length[{i}] - Length[{j}]]        /; FreeQ[a, e[__]] && FreeQ[b, e[__]]
(* End of Right Contraction Section *)


(* Begin Scalar Product Section *)
ScalarProduct[_] := $Failed
ScalarProduct[x_, y_] := ScalarProduct[Expand[x], Expand[y]]                                    /;  x =!= Expand[x] || y =!= Expand[y]
ScalarProduct[x_, y_ + z_] := ScalarProduct[x, y] + ScalarProduct[x, z]
ScalarProduct[x_ + y_, z_] := ScalarProduct[x, z] + ScalarProduct[y, z]
ScalarProduct[a_, b_] := a b                                                                       /; FreeQ[a, e[__]] && FreeQ[b, e[__]]
ScalarProduct[a_, (b_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]]] := 0              /; FreeQ[a, e[__]]
ScalarProduct[(b_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], a_] := 0              /; FreeQ[a, e[__]]
ScalarProduct[(a_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], (b_: 1) e[j__ /; SubsetQ[Range[Plus @@ $SetSignature],{j}]]] := 
              a b Grade[e[i,j], 0]        /; FreeQ[a, e[__]] && FreeQ[b, e[__]] 
(* End of Inner Product Section *)

(* Begin Outer Product Section *)
OuterProduct[_] := $Failed
OuterProduct[x_, y_] :=  OuterProduct[Expand[x], Expand[y]]   /;  x =!= Expand[x] || y =!= Expand[y]
OuterProduct[x_, y_, z__] := Fold[OuterProduct, x, {y, z}] // Simplify
OuterProduct[x_, y_ + z_] := OuterProduct[x, y] + OuterProduct[x, z]
OuterProduct[x_ + y_, z_] := OuterProduct[x, z] + OuterProduct[y, z]
OuterProduct[a_, b_] := a b        /; FreeQ[a, e[__]] && FreeQ[b, e[__]]
OuterProduct[a_, (b_: 1) e[i__ /; SubsetQ[{0, 1, 2, 3, \[Infinity]}, {i}]]] := a b e[i]       /; FreeQ[a, e[__]]
OuterProduct[(b_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], a_] := a b e[i]       /; FreeQ[a, e[__]]
OuterProduct[(a_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]], (b_: 1) e[j__ /; SubsetQ[Range[Plus @@ $SetSignature],{j}]]] :=
              Grade[a b e[i,j], Length[{i}] + Length[{j}]]        /;  FreeQ[a, e[__]] && FreeQ[b, e[__]]
(* End of Outer Product Section *)


(* Begin Turn Section *)
Turn[_] := $Failed
Turn[x_] := Turn[Expand[x]]                                                               /; x =!= Expand[x]
Turn[a_] := a                                                                             /; FreeQ[a, e[__]]
Turn[(a_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]]] := a e @@ Reverse[{i}]  /; FreeQ[a, e[__]]
Turn[x_ + y_] := Turn[x] + Turn[y]
(* End of Turn Section *)

(* Begin Involution Section *)
Involution[_] := $Failed
Involution[x_] := Involution[Expand[x]]                                                            /; x =!= Expand[x]
Involution[a_] := a                                                                       			 /; FreeQ[a, e[__]]
Involution[(a_: 1) e[i__ /; SubsetQ[Range[Plus @@ $SetSignature],{i}]]] := (-1)^Length[{i}] a e[i]  /; FreeQ[a, e[__]]
Involution[x_ + y_] := Involution[x] + Involution[y]
(* End of Involution Section *)

(*  Magnitude function *)
Magnitude[v_] := Sqrt[Grade[GeometricProduct[v,Turn[v]],0]]

(* Dual function *)
Dual[v_, n_ /; Element[n, Integers] && n > 0] := GeometricProduct[v,Turn[Pseudoscalar[n]]]

(* Meet function according Hestenes and Sobzcyk definition (Eq. 2.28) *)
Meet[x_, y_, n_] := With[{met=(-1)^(n (n - 1)/2) Dual[OuterProduct[Dual[x, n], Dual[y, n]],n]}, met/Magnitude[met]]

(* Join function according Dorst et al. (Eq. 5.5) *)
Joint[x_, y_, n_] := OuterProduct[x, InnerProduct[MultivectorInverse[Meet[x, y, n]], y]]

(* Begin MultivectorInverse function *)
MultivectorInverse[v_] := If[Magnitude[v] != 0, Turn[v] / Magnitude[v]^2, Print["Non invertible multivector"]] 
(* End of MultivectorInverse *)


(* ToBasis function *)
ToBasis[x_?VectorQ] := Dot[x, List @@ e /@ Range[Length[x]]]


(* Begin  ToVector funtion *)
ToVector[v_, d_: 3]:= Table[Coefficient[v, e[i]], {i, dimensions[v]}] /; HomogeneousQ[v,1] 
(* End of ToVector *)


(* Coeff function *)
Coeff[x_,y_] := Grade[Coefficient[Expand[x],y],0]


(* definitions for system functions *)
SetAttributes[e,NHoldAll]

(* Restore protection of the functions *)
(* Protect[Evaluate[protected]] *)


End[]  (* End the Private Context *)


(* Protect exported symbols *)

Protect[ e, GeometricProduct, Grade, Turn, Involution, Magnitude, Dual, InnerProduct,
         LeftContraction, LeftContraction, ScalarProduct, OuterProduct, 
         MultivectorInverse, HomogeneousQ, ToBasis, ToVector, Coeff
       ]

EndPackage[]  (* End the Package Context *)