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

    Plugins Class for the Mufasa Macro Library
}

unit plugins;

{$mode objfpc}{$H+}

interface

{$define callconv:=
    {$IFDEF WINDOWS}{$IFDEF CPU32}cdecl;{$ELSE}{$ENDIF}{$ENDIF}
    {$IFDEF LINUX}{$IFDEF CPU32}cdecl;{$ELSE}{$ENDIF}{$ENDIF}
}

uses
  Classes, SysUtils, dynlibs, libloader;

const
  // stdcall
  cv_StdCall = 0;

  // register call
  cv_Register = 1;

  // default (cdecl where supported) otherwise native platform convention
  cv_default = 2;

type
  TPasScriptType = record
    TypeName, TypeDef: string;
  end;

  TMPluginMethod = record
    FuncPtr: pointer;
    FuncStr: string;
    FuncConv: integer;
  end;

  TMPlugin = record
    Methods: array of TMPluginMethod;
    MethodLen: integer;
    Types: array of TPasScriptType;
    TypesLen: integer;
    MemMgrSet: boolean;
    ABI: Integer;
  end;
  TMPluginArray = array of TMPlugin;

  { TMPlugins }

  TMPlugins = class (TGenericLoader)
    private
      Plugins: TMPluginArray;
      NumPlugins: integer;
    protected
      function InitPlugin(plugin: TLibHandle): boolean; override;
    public
      property MPlugins: TMPluginArray read Plugins;
      property Count: integer read NumPlugins;
  end;

implementation

uses
  MufasaTypes, FileUtil;

{ TMPlugins }
function TMPlugins.InitPlugin(Plugin: TLibHandle): boolean;
var
  GetFuncCount: function: integer; stdcall;
  GetFuncInfo: function(x: Integer; var ProcAddr: Pointer; var ProcDef: PChar): integer; stdcall;
  GetFuncConv: function(x: integer): integer; stdcall;

  GetTypeCount: function: integer; stdcall;

  // ABI = 0
  GetTypeInfo0: function(x: Integer; var sType, sTypeDef: string): integer; stdcall;

  // ABI = 1
  GetTypeInfo1: function(x: Integer; var sType, sTypeDef: PChar): integer; stdcall;

  GetPluginABIVersion: function: Integer; {$callconv}

  SetPluginMemManager: procedure(MemMgr : TMemoryManager); stdcall;
  OnAttach: procedure(info: Pointer); stdcall;
  PD, PD2: PChar;
  pntr: Pointer;
  ArrC, I: integer;

  // Memory manager. We use this to retrieve our own memory manager and pass it
  // to the plugin to simplify sharing of memory with FPC plugins.
  MemMgr : TMemoryManager;

  // Plugin ABI version. Requires due to ABI changes and backwards
  // compatibility.
  PluginVersion: Integer;

  // Strings for ABI = 0
  a, b: String;
begin
  Result := False;

  SetLength(Plugins, NumPlugins + 1);

  // Query ABI. Oldest is 0 (where GetPluginABIVersion is not exported)
  Pointer(GetPluginABIVersion) := GetProcAddress(Plugin, PChar('GetPluginABIVersion'));
  if Assigned(GetPluginABIVersion) then
    PluginVersion := GetPluginABIVersion()
  else
    PluginVersion := 0;

  Plugins[NumPlugins].ABI := PluginVersion;

  Pointer(SetPluginMemManager) := GetProcAddress(Plugin, PChar('SetPluginMemManager'));
  if (Assigned(SetPluginMemManager)) then
  begin
    Plugins[NumPlugins].MemMgrSet := True;
    GetMemoryManager(MemMgr);
    SetPluginMemManager(MemMgr);
  end;

  Pointer(OnAttach) := GetProcAddress(Plugin, PChar('OnAttach'));
  if Assigned(OnAttach) then
  begin
    OnAttach(nil);
  end;

  Pointer(GetTypeCount) := GetProcAddress(Plugin, PChar('GetTypeCount'));
  if (Assigned(GetTypeCount)) then
  begin
    case PluginVersion of
      0:
        begin
        Pointer(GetTypeInfo0) := GetProcAddress(Plugin, PChar('GetTypeInfo'));
        if Assigned(GetTypeInfo0) then
        begin
          ArrC := GetTypeCount();

          Plugins[NumPlugins].TypesLen := ArrC;
          SetLength(Plugins[NumPlugins].Types, ArrC);

          for I := 0 to ArrC - 1 do
          begin
            if (GetTypeInfo0(I, a, b) >= 0) then
            begin
              Plugins[NumPlugins].Types[I].TypeName := Copy(a, 1, Length(a));
              Plugins[NumPlugins].Types[I].TypeDef := Copy(b, 1, Length(b));
            end
            else
            begin
              Plugins[NumPlugins].Types[I].TypeName := '';
              Plugins[NumPlugins].Types[I].TypeDef := '';
            end;
          end;
        end;
        end;
      1:
        begin
        Pointer(GetTypeInfo1) := GetProcAddress(Plugin, PChar('GetTypeInfo'));
        if Assigned(GetTypeInfo1) then
        begin
          ArrC := GetTypeCount();

          PD := StrAlloc(1024);
          PD2 := StrAlloc(1024);

          for I := 0 to ArrC - 1 do
          begin
            if (GetTypeInfo1(I, PD, PD2) >= 0) then
            begin
              Plugins[NumPlugins].Types[I].TypeName := PD;
              Plugins[NumPlugins].Types[I].TypeDef := PD2;
            end
            else
            begin
              Plugins[NumPlugins].Types[I].TypeName := '';
              Plugins[NumPlugins].Types[I].TypeDef := '';
            end;
          end;

          StrDispose(PD);
          StrDispose(PD2);
        end;
        end;
    end;
  end;


  Pointer(GetFuncCount) := GetProcAddress(Plugin, PChar('GetFunctionCount'));
  if (Assigned(GetFuncCount)) then
  begin
    Pointer(GetFuncInfo) := GetProcAddress(Plugin, PChar('GetFunctionInfo'));

    if (Assigned(GetFuncInfo)) then
    begin
      // GetFunctionCallingConv is deprecated with version >= 2
      if PluginVersion < 2 then
        Pointer(GetFuncConv) := GetProcAddress(Plugin, PChar('GetFunctionCallingConv'));

      ArrC := GetFuncCount();
      Plugins[NumPlugins].MethodLen := ArrC;
      SetLength(Plugins[NumPlugins].Methods, ArrC);

      PD := StrAlloc(1024);

      for I := 0 to ArrC - 1 do
      begin;
        if (GetFuncInfo(I, pntr, PD) < 0) then
          Continue;

        Plugins[NumPlugins].Methods[I].FuncPtr := pntr;
        Plugins[NumPlugins].Methods[I].FuncStr := PD;
        if PluginVersion > 1 then
          Plugins[NumPlugins].Methods[I].FuncConv := cv_default
        else
        begin
          Plugins[NumPlugins].Methods[I].FuncConv := cv_stdcall;

          if (Assigned(GetFuncConv)) then
            Plugins[NumPlugins].Methods[I].FuncConv := GetFuncConv(I);
        end;

      end;

      StrDispose(PD);
    end;
  end;

  Inc(NumPlugins);
  Result := True;
end;

end.

