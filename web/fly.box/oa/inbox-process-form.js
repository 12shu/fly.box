﻿!function ($) { $ = fly; window.indexPath = "../"; $.doc.addClass("inbox-process"); $.doc.addClass("p-work-process p-work"); $.box.InboxProcessForm = $.Class({ name: "\u4e8b\u52a1", title: "\u4e8b\u52a1\u529e\u7406", base: $.box.FormBase, getModelUrl: $.base.ajaxUrl("work", "GetAssignToMeWork"), buttons: [], pageFormat: ['<div id=top-empty></div><div id="title-block"><a name=top>{title}</a></div>', "<a id=to-process href=#process class=button-32 ></a>", '<a id=to-top href="#top" class=button-32 ></a>', '<form id="content-block" class="oa-process-form" method="post"></form>', '<div id="summarys"></div><br/>'].join(""), createMembers: function () { this.dWin = window.parent || window; this.indexPath = this.dWin.indexPath || ""; this.$base.createMembers.apply(this, arguments) }, afterCreateForm: function () { var _ = this; this.$base.afterCreateForm.apply(this, arguments); this.attachmentsBox = $("#attachments"); this.contentBox = $("#content"); this.summarysBox = $("#summarys"); this.showAttachments(); this.showSummarys(); this.showContent() }, showContent: function () { var A = this; if (this.model.content.startWith("FILE:")) { var _ = this.model.content.substr(5).split(","); this.contentBox.addClass("oa-content-file").html('<iframe src="../file/open-doc.htm?show-list=0&id={0}&name={1}" class="oa-content-frame" frameborder=0 scrolling=no ></iframe>'.format(_[0], _[1])) } else this.contentBox.addClass("oa-content-text").text(this.model.content); var B = 0, C = setInterval(function () { if (B++ > 8) clearInterval(C); if (Math.max(document.documentElement.scrollHeight, document.body.scrollHeight) > 900) { $("#to-top,#to-process").fadeIn(); clearInterval(C) } }, 2000) }, showAttachments: function () { var A = this.getModelResult.attachments; if (A && A[0]) { var _ = A.select("o=>o.id").join(","), B = A.select(function (A) { return '<a href="../file/open-doc.htm?show-list=0&id={id}&name={name}&ids={1}" target=_blank  title="{name} ({0})">{name}</a>'.format($.sizeFormat(A.size), _, A) }).join(""); this.attachmentsBox.html(B) } else this.attachmentsBox.parent().hide() }, showSummarys: function () { window.commentPage = new $.box.WorkTargetComment(); commentPage.render(this.summarysBox); commentPage.getPageDataFilters = commentPage.postArgs = { infoId: this.modelId, type: "WorkTarget" }; commentPage.showComments(); commentPage.loadPageData("last") } }); ["../../fly.common/fly.ui/plugins/themes/plain/simple-pager.css?" + $.pathPart, "../themes/box-default/comment.css?" + $.pathPart, "../themes/box-default/oa/css.css?" + $.pathPart].each($.Style.loadCss); $.loadScript("../../fly.common/fly.ui/plugins/pager/simple.js?" + $.pathPart, function () { $.loadScript("../comment/comment.js?" + $.pathPart, function () { $.box.WorkTargetComment = $.Class({ base: $.box.Comment, noCommentContent: "", saveButtonText: "\u529e\u7406", cancelButtonText: "\u8fd4\u56de", createMembers: function () { this.$base.createMembers.apply(this, arguments); this.txtComment.before("<dl class=txt-summary-label-block >" + "<label><a name=process >\u529e\u7406\u6458\u8981\uff1a</a></label>" + "</dl>") }, saveUrl: $.box.ajaxUrl("work", "ProcessWork"), beforeSave: function ($) { if (!$.content) if (!confirm("\u4f60\u6ca1\u6709\u586b\u5199\u529e\u7406\u6458\u8981\uff01\r\n\u8981\u7ee7\u7eed\u63d0\u4ea4\u5417\uff1f\uff1f")) { this.txtComment.focus(); return false } return true }, cancel: function () { location.href = "list.htm?m=oa&list=inbox" } }); window.page = new $.box.InboxProcessForm(); page.show() }) }) } ()