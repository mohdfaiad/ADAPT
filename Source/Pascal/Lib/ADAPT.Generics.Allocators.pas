{
  AD.A.P.T. Library
  Copyright (C) 2014-2016, Simon J Stuart, All Rights Reserved

  Original Source Location: https://github.com/LaKraven/ADAPT

  Formerlly known as "LaKraven Studios Standard Library" or "LKSL".
  "ADAPT" supercedes the former LKSL codebase as of 2016.

  License:
    - You may use this library as you see fit, including use within commercial applications.
    - You may modify this library to suit your needs, without the requirement of distributing
      modified versions.
    - You may redistribute this library (in part or whole) individually, or as part of any
      other works.
    - You must NOT charge a fee for the distribution of this library (compiled or in its
      source form). It MUST be distributed freely.
    - This license and the surrounding comment block MUST remain in place on all copies and
      modified versions of this source code.
    - Modified versions of this source MUST be clearly marked, including the name of the
      person(s) and/or organization(s) responsible for the changes, and a SEPARATE "changelog"
      detailing all additions/deletions/modifications made.

  Disclaimer:
    - Your use of this source constitutes your understanding and acceptance of this
      disclaimer.
    - Simon J Stuart, nor any other contributor, may be held liable for your use of this source
      code. This includes any losses and/or damages resulting from your use of this source
      code, be they physical, financial, or psychological.
    - There is no warranty or guarantee (implicit or otherwise) provided with this source
      code. It is provided on an "AS-IS" basis.

  Donations:
    - While not mandatory, contributions are always appreciated. They help keep the coffee
      flowing during the long hours invested in this and all other Open Source projects we
      produce.
    - Donations can be made via PayPal to PayPal [at] LaKraven (dot) Com
                                          ^  Garbled to prevent spam!  ^
}
unit ADAPT.Generics.Allocators;

{$I ADAPT.inc}

interface

uses
  {$IFDEF ADAPT_USE_EXPLICIT_UNIT_NAMES}
    System.Classes, System.SysUtils,
  {$ELSE}
    Classes, SysUtils,
  {$ENDIF ADAPT_USE_EXPLICIT_UNIT_NAMES}
  ADAPT.Common, ADAPT.Common.Intf,
  ADAPT.Generics.Defaults.Intf,
  ADAPT.Generics.Allocators.Intf;

  {$I ADAPT_RTTI.inc}

type
  ///  <summary><c>An Allocation Algorithm for Lists.</c></summary>
  ///  <remarks><c>Dictates how to grow an Array based on its current Capacity and the number of Items we're looking to Add/Insert.</c></remarks>
  TADCollectionExpander = class abstract(TADObject, IADCollectionExpander)
  public
    ///  <summary><c>Override this to implement the actual Allocation Algorithm</c></summary>
    ///  <remarks><c>Must return the amount by which the Array has been Expanded.</c></remarks>
    function CheckExpand(const ACapacity, ACurrentCount, AAdditionalRequired: Integer): Integer; virtual; abstract;
  end;

  ///  <summary><c>The Default Allocation Algorithm for Lists.</c></summary>
  ///  <remarks><c>By default, the Array will grow by 1 each time it becomes full</c></remarks>
  TADCollectionExpanderDefault = class(TADCollectionExpander)
  public
    function CheckExpand(const ACapacity, ACurrentCount, AAdditionalRequired: Integer): Integer; override;
  end;

  ///  <summary><c>A Geometric Allocation Algorithm for Lists.</c></summary>
  ///  <remarks>
  ///    <para><c>When the number of Vacant Slots falls below the Threshold, the number of Vacant Slots increases by the value of the current Capacity multiplied by the Mulitplier.</c></para>
  ///    <para><c>This Expander Type is NOT Threadsafe.</c></para>
  ///  </remarks>
  TADCollectionExpanderGeometric = class(TADCollectionExpander, IADCollectionExpanderGeometric)
  private
    FMultiplier: Single;
    FThreshold: Integer;
  protected
    // Getters
    function GetCapacityMultiplier: Single; virtual;
    function GetCapacityThreshold: Integer; virtual;
    // Setters
    procedure SetCapacityMultiplier(const AMultiplier: Single); virtual;
    procedure SetCapacityThreshold(const AThreshold: Integer); virtual;
  public
    function CheckExpand(const ACapacity, ACurrentCount, AAdditionalRequired: Integer): Integer; override;
  public
    // Properties
    property CapacityMultiplier: Single read GetCapacityMultiplier write SetCapacityMultiplier;
    property CapacityThreshold: Integer read GetCapacityThreshold write SetCapacityThreshold;
  end;

  ///  <summary><c>A Geometric Allocation Algorithm for Lists.</c></summary>
  ///  <remarks>
  ///    <para><c>When the number of Vacant Slots falls below the Threshold, the number of Vacant Slots increases by the value of the current Capacity multiplied by the Mulitplier.</c></para>
  ///    <para><c>This Expander Type is Threadsafe.</c></para>
  ///  </remarks>
  TADCollectionExpanderGeometricTS = class(TADCollectionExpanderGeometric, IADReadWriteLock)
  private
    FLock: TADReadWriteLock;
    function GetLock: IADReadWriteLock;
  protected
    // Getters
    function GetCapacityMultiplier: Single; override;
    function GetCapacityThreshold: Integer; override;
    // Setters
    procedure SetCapacityMultiplier(const AMultiplier: Single); override;
    procedure SetCapacityThreshold(const AThreshold: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    property Lock: IADReadWriteLock read GetLock implements IADReadWriteLock;
  end;

  ///  <summary><c>A Deallocation Algorithm for Lists.</c></summary>
  ///  <remarks><c>Dictates how to shrink an Array based on its current Capacity and the number of Items we're looking to Delete.</c></remarks>
  TADCollectionCompactor = class abstract(TADObject, IADCollectionCompactor)
  public
    function CheckCompact(const ACapacity, ACurrentCount, AVacating: Integer): Integer; virtual; abstract;
  end;

  ///  <summary><c>The Default Deallocation Algorithm for Lists.</c></summary>
  ///  <remarks><c>By default, the Array will shrink by 1 each time an Item is removed.</c></remarks>
  TADCollectionCompactorDefault = class(TADCollectionCompactor)
  public
    function CheckCompact(const ACapacity, ACurrentCount, AVacating: Integer): Integer; override;
  end;

  // Class Reference Types
  TADCollectionExpanderType = class of TADCollectionExpander;
  TADCollectionCompactorType = class of TADCollectionCompactor;

  // Exception Types
  EADGenericsExpanderNilException = class(EADGenericsParameterInvalidException);
  EADGenericsCompactorNilException = class(EADGenericsParameterInvalidException);

implementation

{ TADCollectionExpanderDefault }

function TADCollectionExpanderDefault.CheckExpand(const ACapacity, ACurrentCount, AAdditionalRequired: Integer): Integer;
begin
  if ACurrentCount + AAdditionalRequired > ACapacity then
    Result := (ACapacity - ACurrentCount) + AAdditionalRequired
  else
    Result := 0;
end;

{ TADCollectionExpanderGeometric }

function TADCollectionExpanderGeometric.CheckExpand(const ACapacity, ACurrentCount, AAdditionalRequired: Integer): Integer;
begin
  // TODO -oDaniel -cTADCollectionExpanderGeometric: Implement Geometric Expansion Algorithm
  if ACurrentCount + AAdditionalRequired > ACapacity then
    Result := (ACapacity - ACurrentCount) + AAdditionalRequired
  else
    Result := 0;
end;

function TADCollectionExpanderGeometric.GetCapacityMultiplier: Single;
begin
  Result := FMultiplier;
end;

function TADCollectionExpanderGeometric.GetCapacityThreshold: Integer;
begin
  Result := FThreshold;
end;

procedure TADCollectionExpanderGeometric.SetCapacityMultiplier(const AMultiplier: Single);
begin
  FMultiplier := AMultiplier;
end;

procedure TADCollectionExpanderGeometric.SetCapacityThreshold(const AThreshold: Integer);
begin
  FThreshold := AThreshold;
end;

{ TADCollectionExpanderGeometricTS }

constructor TADCollectionExpanderGeometricTS.Create;
begin
  inherited;
  FLock := TADReadWriteLock.Create(Self);
end;

destructor TADCollectionExpanderGeometricTS.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TADCollectionExpanderGeometricTS.GetCapacityMultiplier: Single;
begin
  FLock.AcquireRead;
  try
    Result := inherited;
  finally
    FLock.ReleaseRead;
  end;
end;

function TADCollectionExpanderGeometricTS.GetCapacityThreshold: Integer;
begin
  FLock.AcquireRead;
  try
    Result := inherited;
  finally
    FLock.ReleaseRead;
  end;
end;

function TADCollectionExpanderGeometricTS.GetLock: IADReadWriteLock;
begin
  Result := FLock;
end;

procedure TADCollectionExpanderGeometricTS.SetCapacityMultiplier(const AMultiplier: Single);
begin
  FLock.AcquireWrite;
  try
    inherited;
  finally
    FLock.ReleaseWrite;
  end;
end;

procedure TADCollectionExpanderGeometricTS.SetCapacityThreshold(const AThreshold: Integer);
begin
  FLock.AcquireWrite;
  try
    inherited;
  finally
    FLock.ReleaseWrite;
  end;
end;

{ TADCollectionCompactorDefault }

function TADCollectionCompactorDefault.CheckCompact(const ACapacity, ACurrentCount, AVacating: Integer): Integer;
begin
  Result := AVacating;
end;

end.