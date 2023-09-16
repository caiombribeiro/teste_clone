// Copyright (c) 2022 The Chromium Embedded Framework Authors. All rights
// reserved. Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.
//
// ---------------------------------------------------------------------------
//
// This file was generated by the CEF translator tool. If making changes by
// hand only do so within the body of existing method and function
// implementations. See the translator.README.txt file in the tools directory
// for more information.
//
// $hash=85c8f684b4799cf1410174b0e29a41b192eaf7a4$
//

#ifndef CEF_LIBCEF_DLL_CPPTOC_LIFE_SPAN_HANDLER_CPPTOC_H_
#define CEF_LIBCEF_DLL_CPPTOC_LIFE_SPAN_HANDLER_CPPTOC_H_
#pragma once

#if !defined(WRAPPING_CEF_SHARED)
#error This file can be included wrapper-side only
#endif

#include "include/capi/cef_client_capi.h"
#include "include/capi/cef_life_span_handler_capi.h"
#include "include/cef_client.h"
#include "include/cef_life_span_handler.h"
#include "libcef_dll/cpptoc/cpptoc_ref_counted.h"

// Wrap a C++ class with a C structure.
// This class may be instantiated and accessed wrapper-side only.
class CefLifeSpanHandlerCppToC
    : public CefCppToCRefCounted<CefLifeSpanHandlerCppToC,
                                 CefLifeSpanHandler,
                                 cef_life_span_handler_t> {
 public:
  CefLifeSpanHandlerCppToC();
  virtual ~CefLifeSpanHandlerCppToC();
};

#endif  // CEF_LIBCEF_DLL_CPPTOC_LIFE_SPAN_HANDLER_CPPTOC_H_