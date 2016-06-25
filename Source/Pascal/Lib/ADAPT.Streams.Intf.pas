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
unit ADAPT.Streams.Intf;

{$I ADAPT.inc}

interface

uses
  {$IFDEF ADAPT_USE_EXPLICIT_UNIT_NAMES}
    System.Classes, System.SysUtils,
  {$ELSE}
    Classes, SysUtils,
  {$ENDIF ADAPT_USE_EXPLICIT_UNIT_NAMES}
  ADAPT.Common, ADAPT.Common.Intf;

  {$I ADAPT_RTTI.INC}

type
  { Forward Delcarations }
  IADStream = interface;
  IADStreamManagement = interface;

  { Exceptions }
  EADStreamException = class(EADException);
    EADStreamCaretException = class(EADStreamException);
      EADStreamCaretInvalid = class(EADStreamCaretException);

  ///  <summary><c>A Caret for operating on a Stream at a particular position.</c></summary>
  ///  <remarks><c>A Caret should take responsibility for ensuring any operation affecting OTHER Carets updates those Carets as necessary.</c></remarks>
  IADStreamCaret = interface(IADInterface)
  ['{D8E849E5-A5A1-4B4F-9AF6-BBD397216C5B}']
    // Getters
    function GetIsInvalid: Boolean;
    function GetIsValid: Boolean;
    function GetPosition: Int64;
    function GetStream: IADStream;
    function GetStreamManagement: IADStreamManagement;
    // Setters
    procedure SetPosition(const APosition: Int64);

    // Management Methods
    ///  <summary><c>Deletes the given number of Bytes from the current Position in the Stream, then compacts the Stream by that number of Bytes (shifting any subsequent Bytes to the left)</c></summary>
    ///  <returns><c>Returns the number of Bytes deleted.</c></returns>
    ///  <remarks>
    ///    <para><c>Automatically shifts the Position of subsequent Carets by the offset of Bytes deleted.</c></para>
    ///  </remarks>
    function Delete(const ALength: Int64): Int64;
    ///  <summary><c>Inserts the given Buffer into the current Position within the Stream (shifting any subsequent Bytes to the right)</c></summary>
    ///  <returns><c>Returns the number of Bytes actually written.</c></returns>
    ///  <remarks>
    ///    <para><c>Automatically shifts the Position of subsequent Carets by the offset of Bytes inserted.</c></para>
    ///  </remarks>
    function Insert(const ABuffer; const ALength: Int64): Int64;
    ///  <summary><c>Reads the specified number of Bytes from the Array into the specified Address</c></summary>
    ///  <returns><c>Returns the number of Bytes actually read.</c></returns>
    function Read(var ABuffer; const ALength: Int64): Int64;
    ///  <summary><c>Writes the given Buffer into the current Position within the Stream (overwriting any existing data, and expanding the Size of the Stream if required)</c></summary>
    ///  <returns><c>Returns the number of Bytes actually written.</c></returns>
    function Write(const ABuffer; const ALength: Int64): Int64;
    ///  <returns><c>Returns the new </c>Position<c> in the Stream.</c></returns>
    function Seek(const AOffset: Int64; const AOrigin: TSeekOrigin): Int64;

    ///  <summary><c>Invalidates the Caret.</c></summary>
    ///  <remarks><c>This is usually called by the owning Stream when a Caret has been Invalidated by an operation from another Caret.</c></remarks>
    procedure Invalidate;

    // Properties
    ///  <summary><c>Has an operation on the Stream rendered this Caret invalid?</c></summary>
    property IsInvalid: Boolean read GetIsInvalid;
    ///  <summary><c>If </c>True<c>, this Caret is still Valid.</c></summary>
    property IsValid: Boolean read GetIsValid;
    ///  <summary><c>The Position of this Caret within the Stream.</c></summary>
    property Position: Int64 read GetPosition write SetPosition;
    ///  <summary><c>Reference to the Caret's owning Stream</c></summary>
    property Stream: IADStream read GetStream;
    ///  <summary><c>Reference to the Caret's owning Stream's Management Methods.</c><summary>
    property StreamManagement: IADStreamManagement read GetStreamManagement;
  end;

  ///  <summary><c>A Stream.</c></summary>
  ///  <remarks><c>The Stream enables you to request one or more Carets, and these Carets are used to operate on the Stream.</c></remarks>
  IADStream = interface(IADInterface)
  ['{07F45B12-1DFC-453A-B95C-E00C9F5F4285}']
    // Getters
    function GetSize: Int64;
    // Setters
    procedure SetSize(const ASize: Int64);

    // Management Methods
    ///  <summary><c>Populate the Stream from a File.</c></summary>
    procedure LoadFromFile(const AFileName: String);
    ///  <summary><c>Populate the Stream from the contents of another Stream.</c></summary>
    procedure LoadFromStream(const AStream: IADStream); overload;
    ///  <summary><c>Populate the Stream from the contents of another Stream.</c></summary>
    procedure LoadFromStream(const AStream: TStream); overload;

    ///  <returns><c>A new Stream Caret.</c></returns>
    function NewCaret: IADStreamCaret; overload;
    ///  <returns><c>A new Stream Caret.</c></returns>
    function NewCaret(const APosition: Int64): IADStreamCaret; overload;

    ///  <summary><c>Save contents of the Stream to a File.</c></summary>
    procedure SaveToFile(const AFileName: String);
    ///  <summary><c>Save contents of the Stream to another Stream.</c></summary>
    procedure SaveToStream(const AStream: IADStream); overload;
    ///  <summary><c>Save contents of the Stream to another Stream.</c></summary>
    procedure SaveToStream(const AStream: TStream); overload;

    // Properties
    ///  <summary><c>Size of the Stream.</c></summary>
    property Size: Int64 read GetSize write SetSize;
  end;

  ///  <summary><c>The Stream Management Interface provides access to methods that need to be called internally by a Caret in order to manage other Carets contained by that Stream.</c></summary>
  ///  <remarks><c>This interface is separated to protect an implementing developer from accidentally calling internal Stream Management Methods.</c></remarks>
  IADStreamManagement = interface(IADInterface)
  ['{3FBBB8FD-D115-40FC-9269-FB3C6820794B}']
    procedure InvalidateCaret(const ACaret: IADStreamCaret; const AFromPosition, ACount: Int64);
    procedure InvalidateCarets(const AFromPosition, ACount: Int64);
    procedure ShiftCaretLeft(const ACaret: IADStreamCaret; const AFromPosition, ACount: Int64);
    procedure ShiftCaretRight(const ACaret: IADStreamCaret; const AFromPosition, ACount: Int64);
    procedure ShiftCaretsLeft(const AFromPosition, ACount: Int64);
    procedure ShiftCaretsRight(const AFromPosition, ACount: Int64);
    ///  <summary><c>Removes a Caret from Stream's internal Caret List.</c></summary>
    ///  <remarks>
    ///    <para><c>WARNING - The Stream will no longer be able to manage this Caret.</c></para>
    ///    <para><c>This is called internally by a Caret when it is destroyed.</c></para>
    ///  </remarks>
    procedure UnregisterCaret(const ACaret: IADStreamCaret);
  end;

  IADMemoryStream = interface(IADStream)
  ['{DD2B94EB-B752-4973-8639-833298CD410C}']
  // Getters
  function GetCapacity: Int64;
  // Setters
  procedure SetCapacity(ACapacity: Int64);

  // Properties
  property Capacity: Int64 read GetCapacity write SetCapacity;
  end;

implementation

end.
