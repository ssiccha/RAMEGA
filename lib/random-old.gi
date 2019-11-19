#############################################################################
##
#W  random.gi                         Zsolt Adam Balogh <baloghzsa@gmail.com>
#W                                       Vasyl Laver  <vasyllaver@uzhnu.edu.ua>
##
##
#H  @(#)$Id: random.gi,v 1.00 $
##
#Y  Copyright (C)  2018,  UAE University, UAE
##
#############################################################################
##
##  This file contains random methods for group algebras.
##
#############################################################################
##

#############################################################################
##
##  BasicGroup( <KG> )
##
##  Returns the basic group of the group algebra KG as a subgroup of the
##  normalized group of units.
##
InstallGlobalFunction( BasicGroup, function(kg)
    local emb,g;

    if not(IsGroupRing(kg) or IsGroupAlgebra(kg)) then
	Error("Input should be a Group Ring.");
    fi;
    g:=UnderlyingGroup(kg);
    emb:=Embedding(g,kg);
    return Group(List(g,x->x^emb));
end);

#############################################################################
##
##  IsLienEngel( <KG> )
##
##  Returns true if KG is Lie n-Engel.
##  [x,y,y,...,y]=0 for all x,y and the number of y's is n.
##
##
InstallMethod( IsLienEngel, "Group Algebra", true, [IsGroupRing],1,
function(kg)
   local g,ns,er,p,h;

    if not(IsGroupRing(kg) or IsGroupAlgebra(kg)) then
	      Error("Input should be a Group Ring.");
    fi;

   er:=false;
   p:=Characteristic(kg);
   if IsPrime(p) then
      g:=UnderlyingGroup(kg);
      if not(IsAbelian(g)) and IsNilpotent(g) then
	       ns:=NormalSubgroups(g);
	       for h in ns do
#	  if ( IsPPrimePower(Order(g)/Order(h),p) and IsPGroup(DerivedSubgroup(h))  ) then
#    	  if ( IsPosInt(LogInt(Order(g)/Order(h),p)) and IsPGroup(DerivedSubgroup(h))  ) then
          if ((p^(LogInt(Order(g)/Order(h),p))=Order(g)/Order(h)) and IsPGroup(DerivedSubgroup(h))  ) then
        	   if PrimePGroup(DerivedSubgroup(h))=p then
			            er:=true;
		         fi;
	        fi;
	       od;
     fi;
   else er:=true;
   fi;
   return er;
end);


#############################################################################
##
##  RandomLienEngelLength( <KG,n> )
##
##  Returns the Lie n-Engel length of KG by random way.
##  [x,y,y,...,y]=0 for all x,y and the number of y's is the Lie n-Engel length.
##
##
InstallMethod( RandomLienEngelLength, "Group Algebra, Number of iterations", true, [IsGroupRing, IsPosInt],2,
function(kg,n)
	local g,er,i,j,x,y,max;

	if not(IsGroupRing(kg) or IsGroupAlgebra(kg)) then
	      Error("Input should be a Group Ring.");
	fi;
	if not(IsLienEngel(kg)) then
	      Error("The group ring is not Lie n-Engel");
	fi;
	max:=0;
    g:=BasicGroup(kg);
    for j in [1..n] do
       x:=Random(kg);
       for i in g do
         y:=i;
         er:=0;
         repeat
           y:=RAMEGA_LieComm(y,x);
           er:=er+1;
         until(y=Zero(kg));
		 if (max < er) then
		   max:=er;
		 fi;
       od;
    od;
    return max;
end);

#############################################################################
##
##  GetRandomNormalizedUnit( <KG> )
##
##  Returns a normalized unit of KG by random way.
##
##
InstallMethod( GetRandomNormalizedUnit, "Group Algebra", true, [IsGroupRing],1,
function(kg)
   local x,e;
   e:=One(UnderlyingField(kg));
   repeat
      x:=Random(kg);
   until(Augmentation(x) = e) and x^-1<>fail;
   return x;
end);

#############################################################################
##
##  GetRandomNormalizedUnitaryUnit( <KG> )
##
##  Returns a normalized unit of KG by random way.
##
##
InstallMethod( GetRandomNormalizedUnitaryUnit, "Group Algebra", true, [IsGroupRing],1,
function(kg)
   local x,e;
   e:=One(kg);
   repeat
      x:=GetRandomNormalizedUnit(kg);
   until(x*Involution(x) = e);
   return x;
end);

InstallOtherMethod( GetRandomNormalizedUnitaryUnit, "Group Algebra, Involution", true, [IsGroupRing, IsMapping],2,
function(kg, sigma)
   local x,e;
   e:=One(kg);
   repeat
      x:=GetRandomNormalizedUnit(kg);
   until(x*RAMEGA_InvolutionKG(x,sigma,kg) = e);
   return x;
end);
#############################################################################
##
##  GetRandomUnit( <KG> )
##
##  Returns a unit of KG by random way.
##
##
InstallMethod( GetRandomUnit, "Group Algebra", true, [IsGroupRing],1,
function(kg)
   local x,o;
   o:=Zero(UnderlyingField(kg));
   repeat
      x:=Random(kg);
   until(not(Augmentation(x) = o)) and x^-1<>fail;
   return x;
end);

#############################################################################
##
##  GetRandomElementFromAugmentationIdeal( <KG> )
##
##  Returns a normalized unit of KG by random way.
##
##
InstallMethod( GetRandomElementFromAugmentationIdeal, "Group Algebra", true, [IsGroupRing],1,
function(kg)
   local x,o;
   o:=Zero(UnderlyingField(kg));
   repeat
      x:=Random(kg);
   until(Augmentation(x) = o);
   return x;
end);

#############################################################################
##
##  RandomExponent( <KG,m> )
##
##  Returns the Exponent of the group of normalized units by random way.
##
##
InstallMethod( RandomExponent, "Group Algebra, Number of iterations", true, [IsGroupRing, IsPosInt],2,
function(kg,m)
   local order,x,er,max;
   er:=0;
   max:=1;
   order:=0;
   repeat
     x:=GetRandomNormalizedUnit(kg);
     order:=Order(x);
     er:=er+1;
	 if (max < order) then
	   max:=order;
	 fi;
   until(er = m);
   return max;
end);

#############################################################################
##
##  RandomExponentOfNormalizedUnitsCenter( <KG,m> )
##
##  Returns the exponent of the center of the group of normalized units.
##
##
InstallMethod( RandomExponentOfNormalizedUnitsCenter, "Group Algebra, Number of iterations", true, [IsGroupRing, IsPosInt],2,
function(kg,m)
   local x,e,er,order,max,c;
   er:=0;
   max:=0;
   e:=One(UnderlyingField(kg));
   c:=Center(kg);
   repeat
     x:=Random(c);
     if (Augmentation(x) = e) then
        order:=Order(x);
		if (max < order) then
		  max:=order;
		fi;
        er:=er+1;
     fi;
   until(er = m);
   return max;
end);

#############################################################################
##
##  RandomNilpotencyClass( <KG,m> )
##
##  Returns the nilpotency class of the group of normalized units by random way.
##
##
InstallMethod( RandomNilpotencyClass, "Group Algebra, Number of iterations", true, [IsGroupRing, IsPosInt],2,
function(kg,m)
   local cl,x,y,e,er,class;
   e:=One(kg);
   class:=0;
   er:=1;
   while (er < m) do
     x:=GetRandomNormalizedUnit(kg);
     cl:=0;
     repeat
        y:=GetRandomNormalizedUnit(kg);
        x:=Comm(x,y);
        cl:=cl+1;
     until(x = e);
     if (class < cl) then
	   class:=cl;
	 fi;
     er:=er+1;
   od;
   return class;
end);

#############################################################################
##
##  RandomDerivedLength( <KG,m> )
##
##  Returns the derived length by random way.
##
##
InstallMethod( RandomDerivedLength, "Group Algebra, Number of iterations", true, [IsGroupRing, IsPosInt],2,
function(kg,m)
   local e,n,x,depth,bol;
   e:=One(kg);
   bol:=false;
   depth:=1;
   while(not(bol)) do
     n:=1;
     while(n < m) do
        x:=RAMEGA_GetDerivedDepthN(kg,depth);
        if (not(x=e)) then
           bol:=true;
        fi;
        n:=n+1;
     od;
     if (bol) then
        depth:=depth+1;
        bol:=false;
     else
        bol:=true;
     fi;
   od;
   return depth-1;
end);

##############################################################################
##
##  RandomCommutatorSubgroup( < G, n > )
##
##  Returns the commutator subgroup of G using random method.
##
##
InstallMethod( RandomCommutatorSubgroup, "Group, Number of Iterations", true, [IsGroupRing,IsPosInt],2,
function(KG,n)
    local i,x1,x2,A,g;
	A:=[];
	for i in [1..n] do
    x1:=GetRandomUnit(KG);
	  x2:=GetRandomUnit(KG);
	  AddSet(A,x1^-1*x2^-1*x1*x2);
	od;
	return Group(A);
end);

InstallOtherMethod( RandomCommutatorSubgroup, "Group, Number of Iterations", true, [IsGroup,IsPosInt],2,
function(G,n)
    local i,x1,x2,A,g;
	g:=Set(G);
	A:=[];
	for i in [1..n] do
      x1:=Random(g);
	  x2:=Random(g);
	  AddSet(A,Comm(x1,x2));
	od;
	return Group(A);
end);

##############################################################################
##
##  RandomCommutatorSubgroupOfNormalizedUnits( < kg, n > )
##
##  Returns the commutator subgroup of the normalized unit group
##  using random method.
##
InstallMethod( RandomCommutatorSubgroupOfNormalizedUnits, "Group Ring, Number of Iterations", true, [IsGroupRing,IsPosInt],2,
function(kg,n)
    local i,x1,x2,A;
	A:=[];
	for i in [1..n] do
      x1:=GetRandomNormalizedUnit(kg);
	  x2:=GetRandomNormalizedUnit(kg);
	  AddSet(A,Comm(x1,x2));
	od;
	return Group(A);
end);

##############################################################################
##
##  RandomCenterOfCommutatorSubgroup( < kg, n > )
##
##  Returns the center of the commutator subgroup of the normalized
##  unit group using random method.
##
InstallMethod( RandomCenterOfCommutatorSubgroup, "Group Ring, Number of Iterations", true, [IsGroupRing,IsPosInt],2,
function(kg,n)
    local i,x1,x2,A,c,y;
	c:=Center(kg);
	A:=[];
	for i in [1..n] do
    x1:=GetRandomNormalizedUnit(kg);
	  x2:=GetRandomNormalizedUnit(kg);
	  y:=Comm(x1,x2);
	  if (y in c) then
	    AddSet(A,y);
	  fi;
	od;
	return Group(A);
end);

##############################################################################
##
##  RandomNormalizedUnitGroup( < KG > )
##
##  Returns the normalized group of units using random method.
##
##
InstallMethod( RandomNormalizedUnitGroup, "Group Ring", true, [IsGroupRing],1,
function(kg)
    local x,A,g,f,h;
	A:=[];
	g:=UnderlyingGroup(kg);
	f:=UnderlyingField(kg);
	repeat
       x:=GetRandomNormalizedUnit(kg);
	   AddSet(A,x);
	   h:=Group(A);
	until (Number(h) = Number(f)^(Number(g)-1));
	return h;
end);

##############################################################################
##
##  RandomCommutatorSeries( < kg, n > )
##
##  Returns the commutator seires of the normalized unit group using random method.
##
##
InstallMethod( RandomCommutatorSeries, "Group Ring, Number of Iterations", true, [IsGroupRing,IsPosInt],2,
function(kg,n)
    local series,g;
	series:=[RandomNormalizedUnitGroup(kg)];
	g:=RandomCommutatorSubgroupOfNormalizedUnits(kg,n);
	AddSet(series,g);
	repeat
	   g:=RandomCommutatorSubgroup(g,n);
	   Add(series,g);
	until IdGroup(g)=[1,1];
	return series;
end);

##############################################################################
##
##  RandomLowerCentralSeries( < kg, n > )
##
##  Returns the center of the commutator subgroup of the normalized
##  unit group using random method.
##
InstallMethod( RandomLowerCentralSeries, "Group Ring, Number of Iterations", true, [IsGroupRing,IsPosInt],2,
function(kg,n)
    local series,g,m,x1,x2,A,i;
	series:=[RandomNormalizedUnitGroup(kg)];
	g:=RandomCommutatorSubgroupOfNormalizedUnits(kg,n);
	m:=2;
	AddSet(series,g);
	repeat
	    A:=[];
	   	for i in [1..n] do
            x1:=GetRandomNormalizedUnit(kg);
	        x2:=Random(AsSet(series[m]));
	        AddSet(A,Comm(x1,x2));
	    od;
		m:=m+1;
		g:=Group(A);
	    Add(series,g);
	until IdGroup(g)=[1,1];
	return series;
end);

#############################################################################
##
##  RandomUnitaryOrder( <kg,n> )
##
##  Returns the order of unitary subgroup of normalized group of units
##  where p=char(k) and g is a finite p-group by random way.
##
InstallMethod( RandomUnitaryOrder, "Group Ring, Number of Iterations", true, [IsGroupRing,IsPosInt],2,
function(kg,n)

  local x,a,b,e,k,g,order,ret,p;
  k:=UnderlyingField(kg);
  g:=UnderlyingGroup(kg);
  p:=Characteristic(k);
  if ( 1 < Characteristic(k) and  IsPGroup(g) ) then
		order:=Number(k)^(Number(g)-1);
		e:=One(kg);
		a:=0;
		b:=0;
		while (not a = n) do
			x:=GetRandomNormalizedUnit(kg);
			a:=a+1;
			if (x*Involution(x) = e) then
				b:=b+1;
			fi;
		od;
  if (b=0) then
     return 0;
  fi;
  ret:=0;
  order:=order*b/a;
  while not(p^ret < order and order < p^(ret+1)) do
    ret:=ret+1;
  od;
  if (order - p^ret > p^(ret+1)-order ) then
     ret:=ret+1;
  fi;
  return p^ret;
  else
      Error("The characteristic of Group Ring is a prime and g is a finite p-group");
      return 0;
  fi;
end);

InstallOtherMethod(RandomUnitaryOrder, "Group Ring, Number of Iterations, Involution", true, [IsGroupRing,IsPosInt,IsMapping],3,
function(kg,n,sigma)

  local x,a,b,e,k,g,order,ret,p;
  k:=UnderlyingField(kg);
  g:=UnderlyingGroup(kg);
  p:=Characteristic(k);
  if ( 1 < Characteristic(k) and  IsPGroup(g) ) then
		order:=Number(k)^(Number(g)-1);
		e:=One(kg);
		a:=0;
		b:=0;
		while (not a = n) do
			x:=GetRandomNormalizedUnit(kg);
			a:=a+1;
			if (x*RAMEGA_InvolutionKG(x,sigma,kg) = e) then
				b:=b+1;
			fi;
		od;
  if (b=0) then
     return 0;
  fi;
  ret:=0;
  order:=order*b/a;
  while not(p^ret < order and order < p^(ret+1)) do
    ret:=ret+1;
  od;
  if (order - p^ret > p^(ret+1)-order ) then
     ret:=ret+1;
  fi;
  return p^ret;
  else
      Error("The characteristic of Group Ring is a prime and g is a finite p-group");
      return 0;
  fi;
end);

#############################################################################
##
##  GetRandomCentralNormalizedUnit( <KG> )
##
##  Returns a central normalized unit by random way.
##
##
InstallMethod( GetRandomCentralNormalizedUnit, "Group Ring", true, [IsGroupRing],1,
function(kg)
   local x,e,c;
   c:=Center(kg);
   e:=One(UnderlyingField(kg));
   repeat
      x:=Random(c);
   until(Augmentation(x) = e);
   return x;
end);

#############################################################################
##
##  RandomCentralUnitaryOrder( <kg,n> )
##
##  Returns the order of center of unitary subgroup of normalized group of units
##  where p=char(k) and g is a finite p-group by random way.
##
InstallMethod( RandomCentralUnitaryOrder, "Group Ring, Number of Iterations", true, [IsGroupRing,IsPosInt],2,
function(kg,n)

  local c,x,a,b,e,k,g,order,ret,p;
  k:=UnderlyingField(kg);
  g:=UnderlyingGroup(kg);
  p:=Characteristic(k);
  c:=Center(kg);
  if ( 1 < Characteristic(k) and  IsPGroup(g) ) then
		order:=Number(c)/Number(k);
		e:=One(kg);
		a:=0;
		b:=0;
		while (not a = n) do
			x:=GetRandomCentralNormalizedUnit(kg);
			a:=a+1;
			if (x*Involution(x) = e) then
				b:=b+1;
			fi;
		od;
  if (b=0) then
     return 0;
  fi;
  ret:=0;
  order:=order*b/a;
  while not(p^ret < order and order < p^(ret+1)) do
    ret:=ret+1;
  od;
  if (order - p^ret > p^(ret+1)-order ) then
     ret:=ret+1;
  fi;
  return p^ret;
  else
      Error("The characteristic of Group Ring is a prime and g is a finite p-group");
      return 0;
  fi;
end);

InstallOtherMethod( RandomCentralUnitaryOrder, "Group Ring, Number of Iterations", true, [IsGroupRing,IsPosInt,IsMapping],3,
function(kg,n,sigma)

  local c,x,a,b,e,k,g,order,ret,p;
  k:=UnderlyingField(kg);
  g:=UnderlyingGroup(kg);
  p:=Characteristic(k);
  c:=Center(kg);
  if ( 1 < Characteristic(k) and  IsPGroup(g) ) then
		order:=Number(c)/Number(k);
		e:=One(kg);
		a:=0;
		b:=0;
		while (not a = n) do
			x:=GetRandomCentralNormalizedUnit(kg);
			a:=a+1;
			if (x*RAMEGA_InvolutionKG(x,sigma,kg) = e) then
				b:=b+1;
			fi;
		od;
  if (b=0) then
     return 0;
  fi;
  ret:=0;
  order:=order*b/a;
  while not(p^ret < order and order < p^(ret+1)) do
    ret:=ret+1;
  od;
  if (order - p^ret > p^(ret+1)-order ) then
     ret:=ret+1;
  fi;
  return p^ret;
  else
      Error("The characteristic of Group Ring is a prime and g is a finite p-group");
      return 0;
  fi;
end);

#############################################################################
##
##  RandomUnitarySubgroup( <KG,n> )
##
##  Returns the group of normalized unitary units by random way.
##
##
InstallMethod( RandomUnitarySubgroup, "Group Algebra, Number of iterations", true, [IsGroupRing, IsPosInt],2,
function(kg,n)
    local A,i,x;

    A:=[];
   	for i in [1..n] do
        x:=GetRandomNormalizedUnitaryUnit(kg);
	    AddSet(A,x);
    od;
	return Group(A);
end);

#############################################################################
##
##  RandomDihedralDepth( <KG,n> )
##
##  Returns the dihedral depth of a group or a group algebra in a random way.
##
##
InstallMethod( RandomDihedralDepth, "Group Algebra, Number of iterations", true, [IsGroupRing, IsPosInt],2,
function(G,m)
local a,b,dd,g,s,k,i,j;

    k:=0;

    for i in [1..m] do
      a:=GetRandomUnit(G); b:=GetRandomUnit(G);
      if Order(a)>=2 and Order(b)>=2 and a*b<>b*a then
        g:=Group(a,b); s:=Size(g);
    #    Print(s,"  ",Exponent(g),"\n");
        if s/Exponent(g)=2 then
          if Size(Filtered(Elements(g),j->Order(j)<=2))>=s/2+2 and s>k then k:=s; fi;
        fi;
      fi;
    od;

    if k<>0 then return LogInt(k,2)-1; else return 0; fi;
end);

InstallOtherMethod( RandomDihedralDepth, "Group Algebra, Number of iterations", true, [IsGroup, IsPosInt],2,
function(G,m)
local a,b,dd,g,s,k,i,j;

    k:=0;

    for i in [1..m] do
      a:=Random(G); b:=Random(G);
      if Order(a)>=2 and Order(b)>=2 and a*b<>b*a then
        g:=Group(a,b); s:=Size(g);
    #    Print(s,"  ",Exponent(g),"\n");
        if s/Exponent(g)=2 then
          if Size(Filtered(Elements(g),j->Order(j)<=2))>=s/2+2 and s>k then k:=s; fi;
        fi;
      fi;
    od;

    if k<>0 then return LogInt(k,2)-1; else return 0; fi;
end);

#############################################################################
##
##  RandomDihedralDepth( <KG,n> )
##
##  Returns the dihedral depth of a group or a group algebra in a random way.
##
##
InstallMethod( RandomQuaternionDepth, "Group Algebra, Number of iterations", true, [IsGroupRing, IsPosInt],2,
function(G,m)
    local a,b,dd,g,s,k,i;

    k:=0;

    for i in [1..m] do
      a:=GetRandomUnit(G); b:=GetRandomUnit(G);
      if Order(a)>=2 and Order(b)>=2 and a*b<>b*a then
        g:=Group(a,b); s:=Size(g);
        if s/Exponent(g)=2 then
          if Size(Filtered(Elements(g),j->Order(j)<=2))=2 and s>k then k:=s; fi;
        fi;
      fi;
    od;

    if k<>0 then return LogInt(k,2)-1; else return 0; fi;
end);

InstallOtherMethod( RandomQuaternionDepth, "Group Algebra, Number of iterations", true, [IsGroup, IsPosInt],2,
function(G,m)
    local a,b,dd,g,s,k,i;

    k:=0;

    for i in [1..m] do
      a:=Random(G); b:=Random(G);
      if Order(a)>=2 and Order(b)>=2 and a*b<>b*a then
        g:=Group(a,b); s:=Size(g);
        if s/Exponent(g)=2 then
          if Size(Filtered(Elements(g),j->Order(j)<=2))=2 and s>k then k:=s; fi;
        fi;
      fi;
    od;

    if k<>0 then return LogInt(k,2)-1; else return 0; fi;
end);

#E
##