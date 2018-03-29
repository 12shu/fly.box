# Copyright 2012 Mozilla Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Main toolbar buttons (tooltips and alt text for images)
previous.title=上一页
previous_label=上一页
next.title=下一页
next_label=下一页

# LOCALIZATION NOTE (page_label, page_of):
# These strings are concatenated to form the "Page: X of Y" string.
# Do not translate "{{pageCount}}", it will be substituted with a number
# representing the total number of pages.
page_label=页面：
page_of=/ {{pageCount}}

zoom_out.title=缩小
zoom_out_label=缩小
zoom_in.title=放大
zoom_in_label=放大
zoom.title=缩放
presentation_mode.title=切换到演示模式
presentation_mode_label=演示模式
open_file.title=打开文件
open_file_label=打开
print.title=打印
print_label=打印
download.title=下载
download_label=下载
bookmark.title=当前视图（复制或在新窗口中打开）
bookmark_label=当前视图

# Secondary toolbar and context menu
tools.title=工具
tools_label=工具
first_page.title=转到第一页
first_page.label=转到第一页
first_page_label=转到第一页
last_page.title=转到最后一页
last_page.label=转到最后一页
last_page_label=转到最后一页
page_rotate_cw.title=顺时针旋转
page_rotate_cw.label=顺时针旋转
page_rotate_cw_label=顺时针旋转
page_rotate_ccw.title=逆时针旋转
page_rotate_ccw.label=逆时针旋转
page_rotate_ccw_label=逆时针旋转

hand_tool_enable.title=启用手形工具
hand_tool_enable_label=启用手形工具
hand_tool_disable.title=禁用手形工具
hand_tool_disable_label=禁用手形工具

# Document properties dialog box
document_properties.title=文档属性…
document_properties_label=文档属性…
document_properties_file_name=文件名:
document_properties_file_size=文件大小:
document_properties_kb={{size_kb}} KB ({{size_b}} 字节)
document_properties_mb={{size_mb}} MB ({{size_b}} 字节)
document_properties_title=标题:
document_properties_author=作者:
document_properties_subject=主题:
document_properties_keywords=关键词:
document_properties_creation_date=创建日期:
document_properties_modification_date=修改日期:
document_properties_date_string={{date}}, {{time}}
document_properties_creator=创建者:
document_properties_producer=PDF 制作者:
document_properties_version=PDF 版本:
document_properties_page_count=页数:
document_properties_close=关闭

# Tooltips and alt text for side panel toolbar buttons
# (the _label strings are alt text for the buttons, the .title strings are
# tooltips)
toggle_sidebar.title=切换侧栏
toggle_sidebar_label=切换侧栏
outline.title=显示文档大纲
outline_label=文档大纲
attachments.title=显示附件
attachments_label=附件
thumbs.title=显示缩略图
thumbs_label=缩略图
findbar.title=在文档中查找
findbar_label=查找

# Thumbnails panel item (tooltip and alt text for images)
# LOCALIZATION NOTE (thumb_page_title): "{{page}}" will be replaced by the page
# number.
thumb_page_title=页码 {{page}}
# LOCALIZATION NOTE (thumb_page_canvas): "{{page}}" will be replaced by the page
# number.
thumb_page_canvas=页面 {{page}} 的缩略图

# Find panel button title and messages
find_label=查找：
find_previous.title=查找词语上一次出现的位置
find_previous_label=上一页
find_next.title=查找词语后一次出现的位置
find_next_label=下一页
find_highlight=全部高亮显示
find_match_case_label=区分大小写
find_reached_top=到达文档开头，从末尾继续
find_reached_bottom=到达文档末尾，从开头继续
find_not_found=词语未找到

# Error panel labels
error_more_info=更多信息
error_less_info=更少信息
error_close=关闭
# LOCALIZATION NOTE (error_version_info): "{{version}}" and "{{build}}" will be
# replaced by the PDF.JS version and build ID.
error_version_info=PDF.js v{{version}} (build: {{build}})
# LOCALIZATION NOTE (error_message): "{{message}}" will be replaced by an
# english string describing the error.
error_message=信息：{{message}}
# LOCALIZATION NOTE (error_stack): "{{stack}}" will be replaced with a stack
# trace.
error_stack=堆栈：{{stack}}
# LOCALIZATION NOTE (error_file): "{{file}}" will be replaced with a filename
error_file=文件：{{file}}
# LOCALIZATION NOTE (error_line): "{{line}}" will be replaced with a line number
error_line=行号：{{line}}
rendering_error=渲染页面时发生错误。

# Predefined zoom values
page_scale_width=适合页宽
page_scale_fit=适合页面
page_scale_auto=自动缩放
page_scale_actual=实际大小

# Loading indicator messages
loading_error_indicator=错误
loading_error=载入PDF时发生错误。
invalid_file_error=无效或损坏的PDF文件。
missing_file_error=缺少PDF文件。
unexpected_response_error=意外的服务器响应。

# LOCALIZATION NOTE (text_annotation_type.alt): This is used as a tooltip.
# "{{type}}" will be replaced with an annotation type from a list defined in
# the PDF spec (32000-1:2008 Table 169 – Annotation types).
# Some common types are e.g.: "Check", "Text", "Comment", "Note"
text_annotation_type.alt=[{{type}} 注解]
password_label=输入密码以打开此 PDF 文件。
password_invalid=密码无效。请重试。
password_ok=确定
password_cancel=取消

printing_not_supported=警告：打印功能不完全支持此浏览器。
printing_not_ready=警告：该 PDF 未完全加载以供打印。
web_fonts_disabled=Web 字体已被禁用：无法使用嵌入的PDF字体。
document_colors_disabled=不允许 PDF 文档使用自己的颜色：浏览器中“允许页面选择自己的颜色”的选项已停用。
