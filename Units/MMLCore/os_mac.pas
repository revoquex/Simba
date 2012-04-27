{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009-2012 by Raymond van Venetië and Merlijn Wajer

    MML is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MML is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MML.  If not, see <http://www.gnu.org/licenses/>.

	See the file COPYING, included in this distribution,
	for details about the copyright.

      Mac OS specific implementation for Mufasa Macro Library
}
{$mode objfpc}{$H+}
unit os_mac;

(*
Stub file for Mac OS X support in Simba.

First, get it compile. Which means, define TNativeWindow to something useful.
Fix any other mistakes I made (I didn't test/compile this)

To actually make it usable:
- At least the core functions need to be completed:
    - GetTargetDimensions, GetMousePosition come to mind.

To pick colours and run scripts, implement:
    ReturnData, FreeReturnData

To run scripts with it:
- A lot more functions need to be completed.
    (Mouse+Key stuff)

Wizzup? 28/04/2012
*)

interface

  uses
    Classes, SysUtils, mufasatypes, IOManager,
    {xlib, x, xutil, XKeyInput, ctypes, xtest,}
    syncobjs, mufasabase;

  type
    {
    TKeyInput = class(TXKeyInput)
      public
        procedure Down(Key: Word);
        procedure Up(Key: Word);
    end;
    }

    {
    TNativeWindow = x.TWindow;
    }

    { TWindow }

    TWindow = class(TWindow_Abstract)
      public
        constructor Create();
        destructor Destroy; override;
        procedure GetTargetDimensions(out w, h: integer); override;
        procedure GetTargetPosition(out left, top: integer); override;
        function ReturnData(xs, ys, width, height: Integer): TRetData; override;
        procedure FreeReturnData; override;

        function  GetError: String; override;
        function  ReceivedError: Boolean; override;
        procedure ResetError; override;

        function TargetValid: boolean; override;
        procedure ActivateClient; override;
        procedure GetMousePosition(out x,y: integer); override;
        procedure MoveMouse(x,y: integer); override;
        procedure HoldMouse(x,y: integer; button: TClickType); override;
        procedure ReleaseMouse(x,y: integer; button: TClickType); override;
        function  IsMouseButtonHeld( button : TClickType) : boolean;override;

        procedure SendString(str: string; keywait, keymodwait: integer); override;
        procedure HoldKey(key: integer); override;
        procedure ReleaseKey(key: integer); override;
        function IsKeyHeld(key: integer): boolean; override;
        function GetKeyCode(c : char) : integer;override;

        function GetNativeWindow: TNativeWindow;
      private
    end;

    TIOManager = class(TIOManager_Abstract)
      public
        constructor Create;
        constructor Create(plugin_dir: string);
        function SetTarget(target: TNativeWindow): integer; overload;
        procedure SetDesktop; override;

        function GetProcesses: TSysProcArr; override;
        procedure SetTargetEx(Proc: TSysProc); overload;
      private
        procedure NativeInit; override;
        procedure NativeFree; override;
      public
        display: PDisplay;
        screennum: integer;
        desktop: x.TWindow;
    end;

implementation

uses GraphType, interfacebase, lcltype;

 { TKeyInput }

  procedure TKeyInput.Down(Key: Word);
  begin
  end;

  procedure TKeyInput.Up(Key: Word);
  begin
  end;

  { TWindow }

  function TWindow.GetError: String;
  begin
    Result := 'CompleteMe'; // TODO
  end;

  function  TWindow.ReceivedError: Boolean;
  begin
    result := False; // TODO
  end;

  procedure TWindow.ResetError;
  begin
    // TODO
  end;

  { See if the semaphores / CS are initialised }
  constructor TWindow.Create(display: PDisplay; screennum: integer; window: x.TWindow);
  begin
    // TODO
  end;

  destructor TWindow.Destroy;
  begin
    // TODO
  end;

  function TWindow.GetNativeWindow: TNativeWindow;
  begin
    // TODO
  end;

  procedure TWindow.GetTargetDimensions(out w, h: integer);
  begin
    // TODO
    w := 0;
    h := 0;
  end;

  procedure TWindow.GetTargetPosition(out left, top: integer);
  begin
    // TODO
  end;

  function TWindow.TargetValid: boolean;
  begin
    Result := True; // TODO
  end;

  procedure TWindow.ActivateClient;

  begin
    // TODO
  end;

  function TWindow.ReturnData(xs, ys, width, height: Integer): TRetData;
  begin
    // TODO
  end;

  procedure TWindow.FreeReturnData;
  begin
    // TODO
  end;

  procedure TWindow.GetMousePosition(out x,y: integer);
  begin
    // TODO
    x := 0;
    y := 0;
  end;

  procedure TWindow.MoveMouse(x,y: integer);
  begin
    // TODO
  end;

  procedure TWindow.HoldMouse(x,y: integer; button: TClickType);

  begin
    // TODO
  end;

  procedure TWindow.ReleaseMouse(x,y: integer; button: TClickType);
  begin
    // TODO
  end;

  function TWindow.IsMouseButtonHeld(button: TClickType): boolean;
  begin
    // TODO
  end;

  { TODO: Check if this supports multiple keyboard layouts, probably not }
  procedure TWindow.SendString(str: string; keywait, keymodwait: integer);
  begin
    // TODO
  end;

  procedure TWindow.HoldKey(key: integer);
  begin
    // TODO
    //keyinput.Down(key);
  end;

  procedure TWindow.ReleaseKey(key: integer);
  begin
    // TODO
    //keyinput.Up(key);
  end;

  function TWindow.IsKeyHeld(key: integer): boolean;
  begin
    // TODO
    raise Exception.CreateFmt('IsKeyDown isn''t implemented yet on Mac', []);
  end;

  function TWindow.GetKeyCode(c: char): integer;
  begin
    // TODO
  end;

  { ***implementation*** IOManager }

  constructor TIOManager.Create;
  begin
    inherited Create;
  end;

  constructor TIOManager.Create(plugin_dir: string);
  begin
    inherited Create(plugin_dir);
  end;

  procedure TIOManager.NativeInit;
  begin
    // TODO
  end;

  procedure TIOManager.NativeFree;
  begin
    // TODO
  end;

  procedure TIOManager.SetDesktop;
  begin
    // TODO
    // SetBothTargets(TWindow.Create(display, screennum, desktop));
  end;

  function TIOManager.SetTarget(target: x.TWindow): integer;
  begin
    // TODO
    //result := SetBothTargets(TWindow.Create(display, screennum, target))
  end;

  function TIOManager.GetProcesses: TSysProcArr;
  begin
    // TODO
    raise Exception.Create('GetProcesses: Not Implemented.');
  end;

  procedure TIOManager.SetTargetEx(Proc: TSysProc);
  begin
    // TODO
    raise Exception.Create('SetTargetEx: Not Implemented.');
  end;

end.
