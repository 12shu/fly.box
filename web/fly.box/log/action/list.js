﻿!function () { var $ = fly, J = !!$.getQuery("$with-org"), C = $.getQuery("fileId"), H = $.getQuery("fileName"), _ = $.getQuery("action"), D = $.getQuery("start-time"), A = $.getQuery("end-time"), G = $.getQuery("userId"), I = $.getQuery("userName"), E = [I, H].where("o=>o!=null").join("\u3001"), K = { download: { name: "\u4e0b\u8f7d\u3001\u6d4f\u89c8" }, fav: { name: "\u6536\u85cf" }, praise: { name: "\u8d5e" }, share: { name: "\u5206\u4eab" }, saveTo: { name: "\u8f6c\u5b58" }, score: { name: "\u8bc4\u5206", header: "\u5206\u6570", index: "NumValue" }, comment: { name: "\u8bc4\u8bba", header: "\u5185\u5bb9", index: "Value"} }; action = K[_] || {}; var F = ""; for (var B in K) F += '<option value="{0}" {2} >{1}</option>'.format(B, K[B].name, _ == B ? "selected" : ""); $.box.UploadList = $.Class({ name: "\u65e5\u5fd7", title: "\u6587\u4ef6\u64cd\u4f5c\u65e5\u5fd7" + (E ? "\uff08{0}\uff09".format(E) : ""), base: $.base.ListBase, module: "Log", startTime: D, endTime: A, userId: G, buttons: ['<select id=actions-box class=form-control onchange="page.changeAction()" style="width:auto">{0}</select>'.format(F), '<span title=\u5f00\u59cb\u65f6\u95f4 id="start-time" class="form-control input-append">' + '<input placeholder=\u5f00\u59cb\u65f6\u95f4 data-format="yyyy-MM-dd" type="text" style="width:100px" ondblclick="this.value=\'\'"/>' + '<span class="add-on">' + '<i data-time-icon="icon-time" data-date-icon="icon-calendar">' + "</i></span>" + "</span>", '<span title=\u7ed3\u675f\u65f6\u95f4 id="end-time" class="form-control input-append">' + '<input placeholder=\u7ed3\u675f\u65f6\u95f4 data-format="yyyy-MM-dd" type="text" style="width:100px" ondblclick="this.value=\'\'"/>' + '<span class="add-on">' + '<i data-time-icon="icon-time" data-date-icon="icon-calendar">' + "</i></span>" + "</span>", '<a onclick="page.query()">\u67e5\u8be2</a>'], pageUrl: $.base.ajaxUrl("Log", "FileAction"), defaultStoreArgs: { fileId: C, "start-time": D, "end-time": A, userId: G, action: _ }, gridConfig: { columns: [$.common.createSelection(), { dataIndex: "File", header: "\u6587\u4ef6" }, { dataIndex: "User", header: "\u7528\u6237", renderer: function ($) { return $ + ":" + action.name } }, { dataIndex: "Time", header: "\u65f6\u95f4", renderer: function ($) { return $.format("yyyy-MM-dd HH:mm") } }, { dataIndex: action.index || "Value", header: action.header || ""}] }, changeAction: function () { var _ = { action: $("#actions-box").val(), "start-time": $("#start-time input").val(), "end-time": $("#end-time input").val() }; location.href = $.appendQuery(_) }, query: function () { this.startTime = $("#start-time input").val(); this.endTime = $("#end-time input").val(); $.extend(this.store.params, { "start-time": this.startTime, "end-time": this.endTime, userId: this.userId }); this.pager.go(1, true) }, onInit: function () { setTimeout(function () { page.startPicker = jQuery("#start-time").datetimepicker({ pickTime: false, language: "cn" }); page.endPicker = jQuery("#end-time").datetimepicker({ pickTime: false, language: "cn" }); page.startTime && $("#start-time input").val(page.startTime); page.endTime && $("#end-time input").val(page.endTime) }) } }); $.Style.loadCss("../../../fly.common/bootstrap/css/bootstrap.min.css"); $.Style.loadCss("../../../fly.common/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"); $.loadScript("../../../fly.common/jQuery/jquery.js", function () { $.loadScript("../../../fly.common/bootstrap/js/bootstrap.min.js", function () { $.loadScript("../../../fly.common/bootstrap-datetimepicker/js/bootstrap-datetimepicker.min.js", function () { window.page = new $.box.UploadList(); page.show() }) }) }) } ()