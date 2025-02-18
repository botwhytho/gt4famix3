"
This class encapsulates the logic of the system attraction view. It is applicable to a set of famix types.
"
Class {
	#name : #FAMIXSystemAttraction,
	#superclass : #BrStencil,
	#instVars : [
		'classStrongColor',
		'classPaleColor',
		'methodStrongColor',
		'methodPaleColor',
		'attributeStrongColor',
		'attributePaleColor',
		'types'
	],
	#category : #GToolkit4Famix3
}

{ #category : #'api - instantiation' }
FAMIXSystemAttraction >> create [
	<return: #Object>

	| container |
	container := BlElement new 
	constraintsDo: [:c | 
		c horizontal fitContent. 
		c vertical fitContent ].
	FAMIXSystemAttraction new paint: types in: container.
	container layout: GtGraphForceBasedLayout new.
	^ container asPannableElement
]

{ #category : #'initialize-release' }
FAMIXSystemAttraction >> initialize [ 
	classStrongColor := Color black.
	classPaleColor := Color r: 0.7 g: 0.7 b: 0.7.	

	methodStrongColor := Color r: 1.0 g: 0.3 b: 0.3.
	methodPaleColor := Color r: 1.0 g: 0.7 b: 0.7.
	
	attributeStrongColor := Color r: 0.3 g: 0.3 b: 1.0.
	attributePaleColor := Color r: 0.7 g: 0.7 b: 1.0.
]

{ #category : #rendering }
FAMIXSystemAttraction >> paint: classes in: anElement [
	| methodsToElements attributesToElements allElements classesToElements |
	classesToElements := IdentityDictionary new.
	methodsToElements := IdentityDictionary new.
	attributesToElements := IdentityDictionary new.
	allElements := OrderedCollection new.
	classes do: [ :aClass |
		| classElement |
		classElement := BlElement new 
				geometry: BlEllipseGeometry new;
				border: BlBorder empty;
				size: 10@10;
				background: classStrongColor;
				when: BlClickEvent do: [:e | classElement phlow spawnObject: aClass].
		allElements add: classElement.
		classesToElements at: aClass put: classElement.
		aClass methods do: [ :aMethod |
			| methodElement methodLineElement |
			methodElement := BlElement new 
				geometry: BlEllipseGeometry new;
				border: BlBorder empty;
				size: 6@6;
				background: methodStrongColor;
				when: BlClickEvent do: [:e | methodElement phlow spawnObject: aMethod].
			allElements add: methodElement.
			classElement graph connectTo: methodElement.
			methodLineElement := BlLineElement new
				border: (BlBorder paint: (classPaleColor alpha: 0.3) width: 1);
				constraintsDo: [:c | c ignoreByLayout ];
				zIndex: -1;
				fromAnchor: (BlElementCenterAnchor referenceElement: classElement relatedTo: methodElement);
				toAnchor: (BlElementCenterAnchor referenceElement: methodElement relatedTo: classElement).
			methodLineElement constraints ignoreByLayout.
			allElements add: methodLineElement.
			methodsToElements at: aMethod put: methodElement. ].
		aClass attributes do: [ :anAttribute |
			| attributeElement attributeLineElement |
			attributeElement := BlElement new 
				geometry: BlEllipseGeometry new;
				border: BlBorder empty;
				size: 6@6;
				background: attributeStrongColor;
				when: BlClickEvent do: [:e | attributeElement phlow spawnObject: anAttribute ].
			allElements add: attributeElement.
			classElement graph connectTo: attributeElement.
			attributeLineElement := BlLineElement new
				border: (BlBorder paint: (classPaleColor alpha: 0.3) width: 1);
				constraintsDo: [:c | c ignoreByLayout ];
				zIndex: -1;
				fromAnchor: (BlElementCenterAnchor referenceElement: classElement relatedTo: attributeElement);
				toAnchor: (BlElementCenterAnchor referenceElement: attributeElement relatedTo: classElement).
			attributeLineElement constraints ignoreByLayout.
			allElements add: attributeLineElement.
			attributesToElements at: anAttribute put: attributeElement. ]
	 ].
	classesToElements keysDo: [ :aClass |
		| classElement |
		classElement := classesToElements at: aClass.
		aClass directSuperclasses do: [ :aSuperClass |
			| inheritanceLineElement |
			classesToElements at: aSuperClass ifPresent: [ :superClassElement |
				superClassElement graph connectTo: classElement.
				inheritanceLineElement := BlLineElement new
						border: (BlBorder paint: (classStrongColor alpha: 0.3) width: 1);
						zIndex: -1;
						fromAnchor: (BlElementCenterAnchor referenceElement: classElement relatedTo: superClassElement);
						toAnchor: (BlElementCenterAnchor referenceElement: superClassElement relatedTo: classElement).
				inheritanceLineElement constraints ignoreByLayout.
				allElements add: inheritanceLineElement ] ] ].
	methodsToElements keysDo: [ :aMethod |
		| methodElement |
		methodElement := methodsToElements at: aMethod.
		aMethod invokedMethods do: [ :anInvokedMethod |
			| invocationLineElement |
			anInvokedMethod ~= aMethod ifTrue: [ 
				methodsToElements at: anInvokedMethod ifPresent: [:invokedMethodElement | 
					methodElement graph connectTo: invokedMethodElement.
					invocationLineElement := BlLineElement new
						border: (BlBorder paint: (methodStrongColor alpha: 0.3) width: 1);
						zIndex: -1;
						fromAnchor: (BlElementCenterAnchor referenceElement: methodElement relatedTo: invokedMethodElement);
						toAnchor: (BlElementCenterAnchor referenceElement: invokedMethodElement relatedTo: methodElement).
					invocationLineElement constraints ignoreByLayout.
					allElements add: invocationLineElement ] ] ] ].
	attributesToElements keysDo: [ :anAttribute | 
		| attributeElement |
		attributeElement := attributesToElements at: anAttribute.
		anAttribute accessingMethods do: [ :aMethod |
			| accessLineElement |
			methodsToElements at: aMethod ifPresent: [: methodElement |
				methodElement graph connectTo: attributeElement .
				accessLineElement := BlLineElement new
					border: (BlBorder paint: (attributeStrongColor alpha: 0.3) width: 1);
					zIndex: -1;
					fromAnchor: (BlElementCenterAnchor referenceElement: methodElement relatedTo: attributeElement);
					toAnchor: (BlElementCenterAnchor referenceElement: attributeElement relatedTo: methodElement).
				accessLineElement constraints ignoreByLayout.
				allElements add: accessLineElement ] ] ].
	anElement addChildren: allElements

	"view nodes
		ellipse: [ :each :ellipse | 
			ellipse
				border: BlBorder empty;
				size: 6@6;
				background: ((strongClasses includes: each parentType) 
					ifTrue: [ methodStrongColor ]
					ifFalse: [ methodPaleColor ]) ];
		with: methods.	
	view nodes
		ellipse: [ :each :ellipse | 
			ellipse
				border: BlBorder empty;
				size: 6@6;
				background: ((strongClasses includes: each parentType) 
					ifTrue: [ attributeStrongColor ]
					ifFalse: [ attributePaleColor ]) ];
		with: attributes.
	view edges 
		stencil: [ :each | 
			BlLineElement new
				zIndex: -1; 
				border: (BlBorder 
					paint: ((strongClasses includes: each) 
						ifTrue: [ classPaleColor alpha: 0.3 ]
						ifFalse: [ classPaleColor alpha: 0.3]) width: 1) ];
		connect: classes from: #yourself to: #superclass.
	view edges
		stencil: [ :each :fromElement :toElement | 
			BlLineElement new 
				zIndex: -1;
				border: (BlBorder 
					paint: ((strongClasses includes: fromElement graph model) 
						ifTrue: [ classPaleColor alpha: 0.3 ]
						ifFalse: [ classPaleColor alpha: 0.3]) width: 1) ];
		connect: classes from: #yourself toAll: #methods.
	view edges
		stencil: [ :each :fromElement :toElement | 
			BlLineElement new 
				zIndex: -1;
				border: (BlBorder 
					paint: ((strongClasses includes: fromElement graph model) 
						ifTrue: [ classPaleColor alpha: 0.3 ]
						ifFalse: [ classPaleColor alpha: 0.3]) width: 1) ];
		connect: classes from: #yourself toAll: #attributes.
	view edges
		stencil: [ :each | 
			BlLineElement new
				zIndex: -1;
				border: (BlBorder 
					paint: ((strongClasses includes: each parentType) 
						ifTrue: [ methodPaleColor alpha: 0.3 ]
						ifFalse: [ methodPaleColor alpha: 0.3]) width: 1) ];
		connect: methods from: #yourself toAll: #invokedMethods.
	view edges
		stencil: [ :each | 
			BlLineElement new
				zIndex: -1;
				border: (BlBorder 
					paint: ((strongClasses includes: each parentType) 
						ifTrue: [ attributePaleColor alpha: 0.3 ]
						ifFalse: [ attributePaleColor alpha: 0.3]) width: 1) ];
		connect:  attributes fromAll: #accessingMethods to: #yourself.
	view layout force"
]

{ #category : #accessing }
FAMIXSystemAttraction >> types [
	^ types
]

{ #category : #accessing }
FAMIXSystemAttraction >> types: anObject [
	types := anObject
]

{ #category : #rendering }
FAMIXSystemAttraction >> view: classes highlighting: strongClasses on: view [
	| methods attributes |

	methods := classes flatCollect: #methods.
	attributes := classes flatCollect: #attributes.

	view nodes
		ellipse: [ :each :ellipse | 
			ellipse
				border: BlBorder empty;
				size: 10@10;
				background: ((strongClasses includes: each) 
					ifTrue: [ classStrongColor ]
					ifFalse: [ classPaleColor ]) ];
		with: classes.
	view nodes
		ellipse: [ :each :ellipse | 
			ellipse
				border: BlBorder empty;
				size: 6@6;
				background: ((strongClasses includes: each parentType) 
					ifTrue: [ methodStrongColor ]
					ifFalse: [ methodPaleColor ]) ];
		with: methods.	
	view nodes
		ellipse: [ :each :ellipse | 
			ellipse
				border: BlBorder empty;
				size: 6@6;
				background: ((strongClasses includes: each parentType) 
					ifTrue: [ attributeStrongColor ]
					ifFalse: [ attributePaleColor ]) ];
		with: attributes.
	view edges 
		stencil: [ :each | 
			BlLineElement new
				zIndex: -1; 
				border: (BlBorder 
					paint: ((strongClasses includes: each) 
						ifTrue: [ classPaleColor alpha: 0.3 ]
						ifFalse: [ classPaleColor alpha: 0.3]) width: 1) ];
		connect: classes from: #yourself to: #superclass.
	view edges
		stencil: [ :each :fromElement :toElement | 
			BlLineElement new 
				zIndex: -1;
				border: (BlBorder 
					paint: ((strongClasses includes: fromElement graph model) 
						ifTrue: [ classPaleColor alpha: 0.3 ]
						ifFalse: [ classPaleColor alpha: 0.3]) width: 1) ];
		connect: classes from: #yourself toAll: #methods.
	view edges
		stencil: [ :each :fromElement :toElement | 
			BlLineElement new 
				zIndex: -1;
				border: (BlBorder 
					paint: ((strongClasses includes: fromElement graph model) 
						ifTrue: [ classPaleColor alpha: 0.3 ]
						ifFalse: [ classPaleColor alpha: 0.3]) width: 1) ];
		connect: classes from: #yourself toAll: #attributes.
	view edges
		stencil: [ :each | 
			BlLineElement new
				zIndex: -1;
				border: (BlBorder 
					paint: ((strongClasses includes: each parentType) 
						ifTrue: [ methodPaleColor alpha: 0.3 ]
						ifFalse: [ methodPaleColor alpha: 0.3]) width: 1) ];
		connect: methods from: #yourself toAll: #invokedMethods.
	view edges
		stencil: [ :each | 
			BlLineElement new
				zIndex: -1;
				border: (BlBorder 
					paint: ((strongClasses includes: each parentType) 
						ifTrue: [ attributePaleColor alpha: 0.3 ]
						ifFalse: [ attributePaleColor alpha: 0.3]) width: 1) ];
		connect:  attributes fromAll: #accessingMethods to: #yourself.
	view layout force
]
