<%--

    Copyright (c) 2001-2002. Department of Family Medicine, McMaster University. All Rights Reserved.
    This software is published under the GPL GNU General Public License.
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

    This software was written for the
    Department of Family Medicine
    McMaster University
    Hamilton
    Ontario, Canada 
 
--%> 
 
<%@ page import="oscar.eform.actions.DisplayImageAction,java.lang.*,java.io.File,oscar.OscarProperties,java.io.*,oscar.eform.*,oscar.eform.data.*,java.util.*,org.apache.log4j.Logger"%>
<!--
/*  Shelter Lee's eForm Generator v4 modified after Amos Raphenya by Peter Hutten-Czapski
 *
 *  eformGenerator.jsp
 *
 *  Created on October 1st, 2010, updated Oct 27th
 *
 */
-->

<%@page import="org.oscarehr.util.MiscUtils"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean"%>
<html>
<head>
<title> <bean:message key="eFormGenerator.title"/></title>

<style type="text/css" media="print">
<!-- CSS Script that removes the whole division when printing -->
.DoNotPrint {
	display: none;
}
<!-- CSS Script that removes textarea and textbox borders when printing -->
.noborder {
	border : 0px;
	background: transparent;
	scrollbar-3dlight-color: transparent;
	scrollbar-3dlight-color: transparent;
	scrollbar-arrow-color: transparent;
	scrollbar-base-color: transparent;
	scrollbar-darkshadow-color: transparent;
	scrollbar-face-color: transparent;
	scrollbar-highlight-color: transparent;
	scrollbar-shadow-color: transparent;
	scrollbar-track-color: transparent;
	background: transparent;
	overflow: hidden;
}
</style>
<style>
span.h1		{font-family: sans-serif; font-size: 14px; font-weight: bolder;}
span.h2		{font-family: sans-serif; font-size: 12px; font-weight: bold; text-decoration: underline;}
span.h3		{font-family: sans-serif; font-size: 12px; font-weight: bold;}
span.h4		{font-family: sans-serif; font-size: 12px; font-weight: normal; text-decoration: underline;}
p, li, span	{font-family: sans-serif; font-size: 12px; font-weight: normal;}
a			{font-family: sans-serif; font-size: 12px; font-weight: normal; color: blue; cursor:pointer;}
</style>

<script type="text/javascript">

function getSignatureIndex(type, inputName) {
	var index = 0;
	for (var j = 0; j < DrawData.length; j++) {
		var RedrawParameter = DrawData[j].split("|");
		if (RedrawParameter[0] == type) {
			index++;
			if (inputName == RedrawParameter[5]) {
				break;
			}
		}
	}
	return index;
}

function getCheckedValue(radioObj) {
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		if(radioObj.checked)
			return String(radioObj.value);
		else
			return String(value);
	for(var k = 0; k < radioLength; k++) {
		if(radioObj[k].checked) {
			return String(radioObj[k].value);
		}
	}
	return "";
} 

var BGWidth = 0;
var BGHeight = 0;
 

function loadImage(){
	var img = document.getElementById('imageName');
	var bg = document.getElementById('BGImage');

	//Boilerplate mod to set the path for image function
	bg.src = ("<%=request.getContextPath()%>"+"/eform/displayImage.do?imagefile="+img.value);	
}

function finishLoadingImage() {

	var img = document.getElementById('imageName');
	var myCnv = document.getElementById('myCanvas');
	var bg = document.getElementById('BGImage');
	
	document.getElementById('OrientCustom').value = document.getElementById('OrientCustomValue').value;
	BGWidth = parseInt(getCheckedValue(document.getElementsByName('Orientation')));
	bg.width = BGWidth;
	BGHeight = bg.height;
	document.getElementById('Wizard').style.left = BGWidth;

	myCnv.style.top = bg.style.top;
	myCnv.style.left = bg.style.left;
	myCnv.width = bg.width;
	myCnv.height = bg.height;

	jg.clear();
	drawPageOutline();
}

function drawPageOutline(){
	if (BGWidth <= 800){
		drawPortraitOutline();
	}else if (BGWidth >800) {
		drawLandscapeOutline();
	}
}

function show(x){
	//expands all if x=all
	if (x == 'all'){
		show('Section1');show('Section2');show('Section3');show('Section4');show('Section5');show('Section6');show('Section7');show('Section8');
	}else{
		//expands section
		document.getElementById(x).style.display = 'block';
	}
}
function hide(x){
	//collapse all if x=all
	if (x == 'all'){
		hide('Section1');hide('Section2');hide('Section3');hide('Section4');hide('Section5');hide('Section6');hide('Section7');hide('Section8');
	}else {
	//collapses section
	document.getElementById(x).style.display = 'none';
	}
}

function toggleView(checked,x){
	if (checked){
		document.getElementById(x).style.display = 'block'
	} else if (!checked){
		document.getElementById(x).style.display = 'none';
	}
}

var scriptelSigBox = "ScriptelSignatureBox";
var freehandSigBox = "FreehandSignatureBox";

function loadInputList(){
	//load checklist of all eform input fields

	var InputList = document.getElementById('InputList');
	//empty InputList
	while (InputList.childNodes.length>0){
		InputList.removeChild(InputList.lastChild);
	}
	//assign input name into variable 'InputName'
	TempData = DrawData;
	for (var j=0; (j < (TempData.length) ); j++){
		var RedrawParameter = TempData[j].split("|");
		var InputType = RedrawParameter[0]
		var InputName = "";

		if (InputType == 'Text'){
			InputName = new String(RedrawParameter[5]);
		}else if (InputType == 'Textbox'){
			InputName= new String(RedrawParameter[5]);
		}else if (InputType == 'Checkbox'){
			InputName = new String(RedrawParameter[3]);
		} else if (InputType == scriptelSigBox || InputType == freehandSigBox) {
			InputName = new String(RedrawParameter[5]);
		}
		//adds InputName as list item in InputList
		var ListItem = document.createElement("li");
		var txt = "<input name='InputChecklist' type='checkbox' id='" + InputName + "' value ='" + InputName+ "'>" + InputName;
		ListItem.innerHTML = txt;
		InputList.appendChild(ListItem);
	}
	if (document.getElementById('preCheckGender').checked){
		ListItem = document.createElement("li");
		ListItem.innerHTML = "<input name='InputChecklist' type='checkbox' id='Male' value ='Male'>Male";
		InputList.appendChild(ListItem);

		ListItem = document.createElement("li");
		ListItem.innerHTML = "<input name='InputChecklist' type='checkbox' id='Female' value ='Female'>Female";
		InputList.appendChild(ListItem);
	}
	if (document.getElementById('AddSignature').checked){
		var div4c = document.getElementById('Section4c');
		var div4b = document.getElementById('Section4b');
		if (!document.getElementById("ScriptelSign").checked && !document.getElementById("FreehandSign").checked) {
			ListItem = document.createElement("li");
			ListItem.innerHTML = "<input name='InputChecklist' type='checkbox' id='SignatureBox' value ='SignatureBox'>SignatureBox";
			InputList.appendChild(ListItem);
		}
	}
}

function addToUserSignatureList(){
	var UserSignatureList = document.getElementById('UserSignatureList');	//adds User Name and Signature Image Filename to UserSignature List, separated by '|'
	var UserName = document.getElementById('UserList').value;
	var FileName = document.getElementById('SignatureList').value;

	var ListItem = document.createElement("li");
	ListItem.setAttribute('name', 'UserSignatureListItem');
	var UserSignature = UserName + '|' + FileName;
	ListItem.innerHTML = UserSignature;
	UserSignatureList.appendChild(ListItem);
}

function emptyUserSignaturelist(){
	var UserSignatureList = document.getElementById('UserSignatureList');	//Empty UserSignature List
	//empty UserSignatureList
	while (UserSignatureList.childNodes.length>0){
		UserSignatureList.removeChild(UserSignatureList.lastChild);
	}
}

function uncheckList(x){
	var List = document.getElementsByName(x);
	for (i=0; i < List.length; i++){
		List[i].checked = false;
	}
}
function checkList(x){
	var List = document.getElementsByName(x);
	for (i=0; i < List.length; i++){
		List[i].checked = true;
	}
}

function changeInput(d,p){
var InputChecklist = document.getElementsByName('InputChecklist');
	for (i=0; i < InputChecklist.length; i++){
		if (InputChecklist[i].checked){
			var n = InputChecklist[i].value;
			TransformInput(n,d,p);
		}
	}
}


function TransformInput(n, d, p){
//parses DrawData and find InputName = n,
//then shift the inputbox p pixels in direction d (up, down, left, right)
// if d = 'width' or 'height', the width and height will change by p pixels

	TempData = DrawData;
	var InputName = ""	//hold InputName
	var	DataNumber	= parseInt(0)	//holds the number that correspond to the order in which the Input is entered into the array
	p = parseInt(p);

	//shift Text, Textbox, Checkboxes
	for (var j=0; (j < (TempData.length)); j++){
		var RedrawParameter = TempData[j].split("|");
		var InputType = RedrawParameter[0]
		if (InputType == 'Text'){
			InputName = new String(RedrawParameter[5]);
			DataNumber = j;
		}else if (InputType == 'Textbox'){
			InputName = new String(RedrawParameter[5]);
			DataNumber = j;
		}else if (InputType == 'Checkbox'){
			InputName = new String(RedrawParameter[3]);
			DataNumber = j;
		} else if (InputType == scriptelSigBox || InputType == freehandSigBox) {
			InputName = new String(RedrawParameter[5]);
			DataNumber = j;
		}
		if (InputName == n){		//if InputName matches n
			var TargetParameter = TempData[DataNumber].split("|");
			var Xcoord = parseInt(TargetParameter[1]);
			var Ycoord = parseInt(TargetParameter[2]);
			var W = parseInt(TargetParameter[3]);
			var H = parseInt(TargetParameter[4]);
			if (d == 'up'){
				Ycoord = Ycoord - p;
				TargetParameter[2] = Ycoord;
			} else if (d == 'down'){
				Ycoord = Ycoord + p;
				TargetParameter[2] = Ycoord;
			} else if (d == 'left'){
				Xcoord = Xcoord - p;
				TargetParameter[1] = Xcoord;
			} else if (d == 'right'){
				Xcoord = Xcoord + p;
				TargetParameter[1] = Xcoord;
			} else if (d == 'width'){
				W = W + p;
				TargetParameter[3] = W;
			} else if (d == 'height'){
				H = H + p;
				TargetParameter[4] = H;
			}
			DrawData[j] = TargetParameter.join("|");
		}
	}
	//shift gender boxes
	if (document.getElementById('preCheckGender').checked){
		if (n == 'Male'){
			if (d == 'up'){
				MTopLeftY = MTopLeftY - p;
			} else if (d == 'down'){
				MTopLeftY = MTopLeftY + p;
			} else if (d == 'left'){
				MTopLeftX = MTopLeftX - p;
			} else if (d == 'right'){
				MTopLeftX = MTopLeftX + p;
			}
		}else if (n == 'Female'){
			if (d == 'up'){
				FTopLeftY = FTopLeftY - p;
			} else if (d == 'down'){
				FTopLeftY = FTopLeftY + p;
			} else if (d == 'left'){
				FTopLeftX = FTopLeftX - p;
			} else if (d == 'right'){
				FTopLeftX = FTopLeftX + p;
			}
		}
	}
	//shift SignatureBox
	if (document.getElementById('AddSignature').checked){
		if(n == 'SignatureBox'){
			if (d == 'up'){
				SignatureHolderY = SignatureHolderY - p;
			}else if (d == 'down'){
				SignatureHolderY = SignatureHolderY + p;
			}else if (d == 'left'){
				SignatureHolderX = SignatureHolderX - p;
			}else if (d == 'right'){
				SignatureHolderX = SignatureHolderX + p;
			}else if (d == 'width'){
				SignatureHolderW = SignatureHolderW + p;
			}else if (d == 'height'){
				SignatureHolderH = SignatureHolderH + p;
			}
		}
	}
		//Redraw boxes after updating coordinates
	RedrawAll();
}


var TopEdge = parseInt(0);
var BottomEdge = parseInt(0);
var LeftEdge = parseInt(0);
var RightEdge = parseInt(0);


function alignInput(edge){
//finds checked InputName, then aligns checked input boxes to top/bottom/left/right edge
	TempData = DrawData;
	var InputChecklist = document.getElementsByName('InputChecklist');
	var InputName = ""	//hold InputName
	var	DataNumber	= parseInt(0)	//holds the number that correspond to the order in which the Input is entered into the array
	var Initialized = false;

	//find the inputs with the most top/bottom/left/right coordinates
	for (i=0; i < InputChecklist.length; i++){

		if (InputChecklist[i].checked){
			var n = InputChecklist[i].value;	//finds name of checked input, assigns it to n

			for (var j=0; (j < (TempData.length)); j++){
				var RedrawParameter = TempData[j].split("|");
				var InputType = RedrawParameter[0]

				if (InputType == 'Text'){
					InputName = new String(RedrawParameter[5]);
					DataNumber = j;
				}else if (InputType == 'Textbox'){
					InputName = new String(RedrawParameter[5]);
					DataNumber = j;
				}else if (InputType == 'Checkbox'){
					InputName = new String(RedrawParameter[3]);
					DataNumber = j;
				} else if (InputType == scriptelSigBox || InputType == freehandSigBox) {
					InputName = new String(RedrawParameter[5]);
					DataNumber = j;
				}
				if (InputName == n){
					var TargetParameter = TempData[DataNumber].split("|");
					var Xcoord = parseInt(TargetParameter[1]);
					var Ycoord = parseInt(TargetParameter[2]);
					if (!Initialized){
						TopEdge = Ycoord;
						BottomEdge = Ycoord;
						LeftEdge = Xcoord;
						RightEdge = Xcoord;
						Initialized = true;
					}

					if (Xcoord < LeftEdge){
						LeftEdge = Xcoord;
					}else if (Xcoord > RightEdge){
						RightEdge = Xcoord;
					}
					if (Ycoord < TopEdge){
						TopEdge = Ycoord;
					}else if (Ycoord > BottomEdge){
						BottomEdge = Ycoord;
					}
				}
			}
			if (document.getElementById('preCheckGender').checked){
				if (n == 'Male'){
					if (!Initialized){
						TopEdge = MTopLeftY;
						BottomEdge = MTopLeftY;
						LeftEdge = MTopLeftX;
						RightEdge = MTopLeftX;
						Initialized = true;
					}
					if (MTopLeftY > BottomEdge){
						BottomEdge = MTopLeftY;
					}else if (MTopLeftY < TopEdge){
						TopEdge = MTopLeftY;
					}
					if (MTopLeftX < LeftEdge){
						LeftEdge = MTopLeftX;
					}else if (MTopLeftX > RightEdge){
						RightEdge = MTopLeftX;
					}
				}else if (n == 'Female'){
					if (!Initialized){
						TopEdge = FTopLeftY;
						BottomEdge = FTopLeftY;
						LeftEdge = FTopLeftX;
						RightEdge = FTopLeftX;
						Initialized = true;
					}
					if (FTopLeftY > BottomEdge){
						BottomEdge = FTopLeftY;
					}else if (FTopLeftY < TopEdge){
						TopEdge = FTopLeftY;
					}
					if (FTopLeftX < LeftEdge){
						LeftEdge = FTopLeftX;
					}else if (FTopLeftX > RightEdge){
						RightEdge = FTopLeftX;
					}
				}
			}
			if (document.getElementById('AddSignature').checked){
				if (n == 'SignatureBox'){
					if (!Initialized){
						TopEdge = SignatureHolderY;
						BottomEdge = SignatureHolderY;
						LeftEdge = SignatureHolderX;
						RightEdge = SignatureHolderX;
						Initialized = true;
					}
					if (SignatureHolderY > BottomEdge){
						BottomEdge = SignatureHolderY;
					}else if (SignatureHolderY < TopEdge){
						TopEdge = SignatureHolderY;
					}
					if (SignatureHolderX < LeftEdge){
						LeftEdge = SignatureHolderX;
					}else if (SignatureHolderX > RightEdge){
						RightEdge = SignatureHolderX;
					}
				}
			}
		}

	}

	//change selected inputs' coordinates to top/bottom/left/right edges
	for (i=0; i < InputChecklist.length; i++){
		if (InputChecklist[i].checked){
			var n = InputChecklist[i].value;	//finds name of checked input, assigns it to n
			for (var j=0; (j < (TempData.length)); j++){
				var RedrawParameter = TempData[j].split("|");
				var InputType = RedrawParameter[0]
				if (InputType == 'Text'){
					InputName = new String(RedrawParameter[5]);
					DataNumber = j;
				}else if (InputType == 'Textbox'){
					InputName = new String(RedrawParameter[5]);
					DataNumber = j;
				}else if (InputType == 'Checkbox'){
					InputName = new String(RedrawParameter[3]);
					DataNumber = j;
				} else if (InputType == scriptelSigBox || InputType == freehandSigBox) {
					InputName = new String(RedrawParameter[5]);
					DataNumber = j;
				}
				if (InputName == n){		//if InputName matches n
					var TargetParameter = TempData[DataNumber].split("|");
					var Xcoord = parseInt(TargetParameter[1]);
					var Ycoord = parseInt(TargetParameter[2]);
					if (edge == 'top'){
						TargetParameter[2] = TopEdge;
					}else if (edge == 'bottom'){
						TargetParameter[2] = BottomEdge;
					}else if (edge == 'left'){
						TargetParameter[1] = LeftEdge;
					}else if (edge == 'right'){
						TargetParameter[1] = RightEdge;
					}
					DrawData[j] = TargetParameter.join("|");
				}
			}
			if (document.getElementById('preCheckGender').checked){
				if (n == 'Male'){
					if (edge == 'bottom'){
						MTopLeftY = BottomEdge;
					}else if (edge == 'top'){
						MTopLeftY = TopEdge;
					}else if (edge == 'left'){
						MTopLeftX = LeftEdge;
					}else if (edge == 'right'){
						MTopLeftX = RightEdge;
					}
				}else if (n == 'Female'){
					if (edge == 'bottom'){
						FTopLeftY = BottomEdge;
					}else if (edge == 'top'){
						FTopLeftY = TopEdge;
					}else if (edge == 'left'){
						FTopLeftX = LeftEdge;
					}else if (edge == 'right'){
						FTopLeftX = RightEdge;
					}
				}
			}
			if (document.getElementById('AddSignature').checked){
				if (n == 'SignatureBox'){
					if (edge == 'bottom'){
						SignatureHolderY = BottomEdge;
					}else if (edge == 'top'){
						SignatureHolderY = TopEdge;
					}
					if (edge == 'left'){
						SignatureHolderX = LeftEdge;
					}else if (edge == 'right'){
						SignatureHolderX = RightEdge;
					}
				}
			}
		}

	}

	//Redraw boxes after updating coordinates
	RedrawAll();
}


function deleteInput(){
	TempData = DrawData;
	var InputChecklist = document.getElementsByName('InputChecklist');
	var InputName = ""	//hold InputName
	var	DataNumber	= parseInt(0)	//holds the number that correspond to the order in which the Input is entered into the array

	//delete checked inputs in the input checklist
	for (i=0; i < InputChecklist.length; i++){

		if (InputChecklist[i].checked){
			var n = InputChecklist[i].value;	//finds name of checked input, assigns it to n

			for (var j=0; (j < (TempData.length)); j++){
				var RedrawParameter = TempData[j].split("|");
				var InputType = RedrawParameter[0]

				if (InputType == 'Text'){
					InputName = new String(RedrawParameter[5]);
					DataNumber = j;
				}else if (InputType == 'Textbox'){
					InputName = new String(RedrawParameter[5]);
					DataNumber = j;
				}else if (InputType == 'Checkbox'){
					InputName = new String(RedrawParameter[3]);
					DataNumber = j;
				} else if (InputType == scriptelSigBox || InputType == freehandSigBox) {
					InputName = new String(RedrawParameter[5]);
					DataNumber = j;
				}
				if (InputName == n){
					TempData.splice(j,1);
				}
			}
		}
	}
	DrawData = TempData;
	//Redraw boxes after updating coordinates
	RedrawAll();
	loadInputList();
}
</script>

<script type="text/javascript">
//output html code for eform

var text = "";
var textTop = "";
var textMiddle = "";
var textBottom = "";

var CheckboxOffset = 4;
var MTopLeftX = 0;
var MTopLeftY = 0;
var FTopLeftX = 0;
var FTopLeftY = 0;
var SignatureHolderX = 0;
var SignatureHolderY = 0;
var SignatureHolderH = 0;
var SignatureHolderW = 0;

var SignatureHolderX1 = 0;
var SignatureHolderY1 = 0;
var SignatureHolderH1 = 0;
var SignatureHolderW1 = 0;

function resetAll(){
	text = "";
	textTop = "";
	textBottom = "";
	textMiddle = "";
	inputName = "";
	inputCounter = 1;
	DrawData = new Array();
	TempData = new Array();

	SetSwitchOn('Text');
	document.getElementById('Text').checked = true;

	document.getElementById('inputValue').value = "";
	document.getElementById('inputName').value = "";
	document.getElementById('preCheck').checked = false;
	document.getElementById('preCheckGender').checked = false;
	document.getElementById('maximizeWindow').checked = false;
	var l = document.getElementById('oscarDB');
		l[0].selected = true;
	document.getElementById('DefaultCheckmark').checked = false;
	clearGraphics(jg);
	finishLoadingImage();
}

function GetTextTop(){
	textTop = "&lt;html&gt;\n&lt;head&gt;\n&lt;title&gt;";
	textTop += document.getElementById('eFormName').value;
	textTop += "&lt;/title&gt;\n&lt;style type=&quot;text/css&quot; media=&quot;print&quot;&gt;\n .DoNotPrint {\n\t display: none;\n }\n .noborder {\n\t border : 0px;\n\t background: transparent;\n\t scrollbar-3dlight-color: transparent;\n\t scrollbar-3dlight-color: transparent;\n\t scrollbar-arrow-color: transparent;\n\t scrollbar-base-color: transparent;\n\t scrollbar-darkshadow-color: transparent;\n\t scrollbar-face-color: transparent;\n\t scrollbar-highlight-color: transparent;\n\t scrollbar-shadow-color: transparent;\n\t scrollbar-track-color: transparent;\n\t background: transparent;\n\t overflow: hidden;\n }\n &lt;/style&gt;\n\n";
	//auto ticking gender boxes
	if (document.getElementById('preCheckGender').checked){
		textTop += "&lt;script type=&quot;text/javascript&quot; language=&quot;javascript&quot;&gt;\n";
		textTop += "function checkGender(){\n";
		textTop += "\t if (document.getElementById(&quot;PatientGender&quot;).value == &quot;M&quot;){\n";
		textTop += "\t document.getElementById(&quot;Male&quot;).checked = true;\n";
		textTop += "\t }else if (document.getElementById(&quot;PatientGender&quot;).value == &quot;F&quot;){\n";
		textTop += "\t document.getElementById(&quot;Female&quot;).checked = true;\n";
		textTop += "\t}\n }\n";
		textTop += "&lt;/script&gt;\n\n";
	}
	//load jsgraphic scripts for drawing in checkbox or freehand signatures
	<% if (!OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>
		if(document.getElementById('DefaultCheckmark').checked 
				|| document.getElementById('FreehandSign').checked
				|| document.getElementById('ScriptelSign').checked){
	<%} else {%>
	if(document.getElementById('DefaultCheckmark').checked){
	<%}%>
		textTop += "&lt;!-- js graphics scripts --&gt;\n";
		textTop += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_javascript_path%7Deforms/jsgraphics.js&quot;&gt;&lt;/script&gt;\n";
	}
	<% if (OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_print_enabled") || OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_fax_enabled") || OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>
	textTop += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_javascript_path%7Djquery/jquery-1.4.2.js&quot;&gt;&lt;/script&gt;\n";
	<% } %>
	
	<% if (OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_print_enabled")) { %>
	textTop += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_javascript_path%7Deforms/printControl.js&quot;&gt;&lt;/script&gt;\n";
	<% } %>
	
	<% if (OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_fax_enabled")) { %>
	if (document.getElementById("includeFaxControl").checked) {
		textTop += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_javascript_path%7Deforms/faxControl.js&quot;&gt;&lt;/script&gt;\n";
	}
	<% } %>	
	
	//load mouse function scripts for freehand signatures
	<% if (!OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>
	if(document.getElementById('FreehandSign').checked) {
		textTop += "&lt;!-- mousefunction scripts --&gt;\n";
		textTop += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_image_path%7Dmouse.js&quot;&gt;&lt;/script&gt;\n\n";
	}
	<%}%>
	
	if (document.getElementById('AddSignature').checked){
	<% if (OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>		
		textTop += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_javascript_path%7Deforms/signatureControl.jsp&quot;&gt;&lt;/script&gt;\n";
		textTop += "&lt;script type=&quot;text/javascript&quot;&gt;";	
		textTop += "if (typeof jQuery != &quot;undefined&quot; &amp;&amp; typeof signatureControl != &quot;undefined&quot;) {";
		textTop += "jQuery(document).ready(function() {";
		textTop += "signatureControl.initialize({eform:true, height:"+SignatureHolderH+", width:"+SignatureHolderW+", top:"+SignatureHolderY+", left:"+SignatureHolderX+"});";
		textTop += "});}";
		textTop +="&lt;/script&gt;\n";
		<% } else { %> //
		textTop += "&lt;script language=&quot;javascript&quot;&gt;\n";
		textTop += "function show(x){\n";
		textTop += "\tdocument.getElementById(x).style.display = &quot;block&quot;;\n";
		textTop += "}\n";
		textTop += "function hide(x){\n";
		textTop += "\tdocument.getElementById(x).style.display = &quot;none&quot;;\n";
		textTop += "}\n";
		textTop += "&lt;/script&gt;\n\n";
		<% } %>
	}
	//printing script
	textTop += "&lt;script language=&quot;javascript&quot;&gt;\n";
	textTop += "function formPrint(){\n";
	//when printing checkmarks, need to move checkmark canvas to the front.
	//After printing, need to move canvas to the back, so that you can interact with form inputs again
	if(document.getElementById('DefaultCheckmark').checked){
		textTop += "\t if (document.getElementById(&quot;DrawCheckmark&quot;).checked){ \n";
		textTop += "\t\t	printCheckboxes();\n";
		textTop += "\t }else{\n";
	}
	textTop += "\t\t	window.print();\n";
	if(document.getElementById('DefaultCheckmark').checked){
		textTop += "\t } \n";
	}
	textTop += "} \n";
	textTop += "&lt;/script&gt;\n\n";

	//Peter Hutten-Czapski's script to confirm closing of window if eform changed
	textTop += "&lt;!-- scripts to confirm closing of window if it hadn't been saved yet --&gt;\n";
	textTop += "&lt;script language=&quot;javascript&quot;&gt;\n";
	textTop += "//keypress events trigger dirty flag\n";
	textTop += "var needToConfirm = false;\n";
	textTop += "document.onkeyup=setDirtyFlag;\n";
	textTop += "function setDirtyFlag(){\n";
	textTop += "\t	needToConfirm = true;\n";
	textTop += "}\n";
	textTop += "function releaseDirtyFlag(){\n";
	textTop += "\t	needToConfirm = false; //Call this function if doesn't requires an alert.\n";
	textTop += "//this could be called when save button is clicked\n";
	textTop += "}\n";
	textTop += "window.onbeforeunload = confirmExit;\n";
	textTop += "function confirmExit(){\n";
	textTop += "\t if (needToConfirm){\n";
	textTop += "\t\t return &quot;You have attempted to leave this page. If you have made any changes to the fields without clicking the Save button, your changes will be lost. Are you sure you want to exit this page?&quot;;\n";
	textTop += "\t }\n";
	textTop += "}\n";
	textTop += "&lt;/script&gt;\n\n";

	//maximize window script
	if (document.getElementById('maximizeWindow').checked){
		textTop += "&lt;script language=&quot;JavaScript&quot;&gt;\n";
		textTop += "\t top.window.moveTo(0,0);\n";
		textTop += "\t if (document.all) {\n";
		textTop += "\t top.window.resizeTo(screen.availWidth,screen.availHeight);\n";
		textTop += "\t }\n";
		textTop += "\t else if (document.layers||document.getElementById) {\n";
		textTop += "\t if (top.window.outerHeight&lt;screen.availHeight||top.window.outerWidth&lt;screen.availWidth){\n";
		textTop += "\t\t top.window.outerHeight = screen.availHeight;\n";
		textTop += "\t\t top.window.outerWidth = screen.availWidth;\n";
		textTop += "\t}\n}\n &lt;/script&gt;\n\n";
	}
	// David Daley and Peter Hutten-Czapski's scripts for scaling up checkboxes
	if (document.getElementById('ScaleCheckmark').checked){
		textTop += "&lt;style type=&quot;Text/css&quot;&gt;\n";
		textTop += "input.largerCheckbox {\n";
		textTop += "\t-moz-transform:scale(1.3);         /*scale up image 1.3x - Firefox specific */ \n";
		textTop += "\t-webkit-transform:scale(1.3);      /*Webkit based browser eg Chrome, Safari */ \n";
		textTop += "\t-o-transform:scale(1.3);           /*Opera browser */ \n";
		textTop += "}\n";
		textTop += "&lt;/style&gt;\n";
		textTop += "&lt;style type=&quot;text/css&quot; media=&quot;print&quot;&gt;\n";
		textTop += "input.largerCheckbox { \n";
		textTop += "\t-moz-transform:scale(1.8);         /*scale up image 1.8x - Firefox specific */ \n";
		textTop += "\t-webkit-transform:scale(1.3);      /*Webkit based browser eg Chrome, Safari */ \n";
		textTop += "\t-o-transform:scale(1.3);           /*Opera browser */ \n";
		textTop += "} \n";
		textTop += "&lt;/style&gt;\n";
		textTop += "&lt;!--[if IE]&gt;\n";
		textTop += "&lt;style type=&quot;text/css&quot;&gt;\n";
		textTop += "input.largerCheckbox { \n";
		textTop += "\theight: 30px;                     /*30px checkboxes for IE 5 to IE 7 */ \n";
		textTop += "\twidth: 30px; \n";
		textTop += "} \n";
		textTop += "&lt;/style&gt; \n";
		textTop += "&lt;![endif]--&gt; \n\n";
	}
	<% if (!OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>
	//autoloading signature images
	var List = document.getElementsByName('UserSignatureListItem');
	if (document.getElementById('AutoSign').checked){
		textTop += "&lt;script type=&quot;text/javascript&quot;&gt;\n";
		textTop += "function preloadImg(){\n";
		textTop += "\t// create object\n";
		textTop += "\timageObj = new Image();\n";
		textTop += "\t// set image list\n";
		textTop += "\timages = new Array();\n";
		for (i=0; i<List.length;i++){
			var ListItem = List[i].innerHTML;
			var ListItemArr =  ListItem.split('|');
			var UserName = ListItemArr[0];
			var FileName = ListItemArr[1];
			textTop +="\timages[" + i + "]=&quot;$%7Boscar_image_path%7D" + FileName + "&quot;\n";
		}
		textTop += "\t// start preloading\n";
		textTop += "\tfor(i=0; i&lt;=images.length; i++){\n";
		textTop += "\t\timageObj.src=images[i];\n";
		textTop += "\t}\n";
		textTop += "}\n\n";
		textTop += "function reloadSignature(){\n";
		textTop += "\tpreloadImg();\n";
		textTop += "\tvar SubmittedBy = document.getElementById(&quot;SubmittedBy&quot;).value;\n";
		textTop += "\tif (!SubmittedBy){\n";
		textTop += "\t\tSignForm(&quot;current_user&quot;);\n";
		textTop += "\t} else {\n";
		textTop += "\t\tSignForm(SubmittedBy);\n";
		textTop += "\t}\n";
		textTop += "\tresizeSignature();\n";
		textTop += "}\n\n";

		textTop += "function SignForm(SignBy){\n";
		textTop += "\tvar SignatureHolder = document.getElementById(&quot;SignatureHolder&quot;);\n";
		textTop += "\tvar DoctorName = document.getElementById(&quot;DoctorName&quot;).value;\n";
		textTop += "\tvar CurrentUserName = document.getElementById(&quot;CurrentUserName&quot;).value;\n";

		textTop += "\t\tif(SignBy == &quot;doctor&quot;){\n";
		var List = document.getElementsByName('UserSignatureListItem');
		for (i=0; i<List.length;i++){
			var ListItem = List[i].innerHTML;
			var ListItemArr =  ListItem.split('|');
			var UserName = ListItemArr[0];
			var FileName = ListItemArr[1];
			if (i <1){
				textTop += "\t\t\tif (DoctorName.indexOf(&quot;" + UserName + "&quot;) &gt;= 0){\n";
				textTop += "\t\t\t\tSignatureHolder.innerHTML = &quot;&lt;img id=\\&quot;SignatureImage\\&quot; src=\\&quot;$%7Boscar_image_path%7D" + FileName + "\\&quot;&gt;&quot;;\n";
			} else if (i>=1){
				textTop += "\t\t\t}else if(DoctorName.indexOf(&quot;" + UserName + "&quot;) &gt;= 0){\n";
				textTop += "\t\t\t\tSignatureHolder.innerHTML = &quot;&lt;img id=\\&quot;SignatureImage\\&quot; src=\\&quot;$%7Boscar_image_path%7D" + FileName + "\\&quot;&gt;&quot;;\n";
			}
		}
		textTop += "\t\t\t} else {\n";
		textTop += "\t\t\t\tSignatureHolder.innerHTML = &quot;&lt;div id=\\&quot;SignatureImage\\&quot;&gt;&lt;/div&gt;&quot;;\n";
		textTop += "\t\t\t}\n";
		textTop += "\t\t\tdocument.getElementById(&quot;SubmittedBy&quot;).value = SignBy;\n";
		textTop += "\t\t}else if (SignBy == &quot;current_user&quot;){\n";
		for (i=0; i<List.length;i++){
			var ListItem = List[i].innerHTML;
			var ListItemArr =  ListItem.split('|');
			var UserName = ListItemArr[0];
			var FileName = ListItemArr[1];
			if (i<1){
				textTop += "\t\t\tif (CurrentUserName.indexOf(&quot;" + UserName + "&quot;) &gt;= 0){\n";
				textTop += "\t\t\t\tSignatureHolder.innerHTML = &quot;&lt;img id=\\&quot;SignatureImage\\&quot; src=\\&quot;$%7Boscar_image_path%7D" + FileName + "\\&quot;&gt;&quot;;\n";
			} else if (i>=1){
				textTop += "\t\t\t}else if(CurrentUserName.indexOf(&quot;" + UserName + "&quot;) &gt;= 0){\n";
				textTop += "\t\t\t\tSignatureHolder.innerHTML = &quot;&lt;img id=\\&quot;SignatureImage\\&quot; src=\\&quot;$%7Boscar_image_path%7D" + FileName + "\\&quot;&gt;&quot;;\n";
			}
		}
		textTop += "\t\t\t} else {\n";
		textTop += "\t\t\t\tSignatureHolder.innerHTML = &quot;&lt;div id=\\&quot;SignatureImage\\&quot;&gt;&lt;/div&gt;&quot;;\n";
		textTop += "\t\t\t}\n";
		textTop += "\t\t\tdocument.getElementById(&quot;SubmittedBy&quot;).value = SignBy;\n";
		textTop += "\t\t}else if (SignBy == &quot;none&quot;){\n";
		textTop += "\t\t\tSignatureHolder.innerHTML = &quot;&lt;div id=\\&quot;SignatureImage\\&quot;&gt;&lt;/div&gt;&quot;;\n";
		textTop += "\t\t}\n";
		textTop += "\t\tresizeSignature();\n";

		textTop += "}\n";

		textTop += "function resizeSignature(){\n";
		textTop += "\t//resize signature image to fit inside SignatureHolder\n";
		textTop += "\tif (document.getElementById(&quot;SignatureImage&quot;)){\n";

		textTop += "\t\tvar Holder = document.getElementById(&quot;SignatureHolder&quot;)\n";
		textTop += "\t\tvar Image = document.getElementById(&quot;SignatureImage&quot;)\n";
		textTop += "\t\tvar HolderW = parseInt(document.getElementById(&quot;SignatureHolder&quot;).style.width);\n";
		textTop += "\t\tvar HolderH = parseInt(document.getElementById(&quot;SignatureHolder&quot;).style.height);\n";
		textTop += "\t\tvar ImageW = document.getElementById(&quot;SignatureImage&quot;).width;\n";
		textTop += "\t\tvar ImageH = document.getElementById(&quot;SignatureImage&quot;).height;\n";
		textTop += "\t\tif (ImageW &gt; HolderW){\n";
		textTop += "\t\t\tImage.style.width = HolderW;\n";
		textTop += "\t\t\tvar NewH = (HolderW * (ImageH/ImageW));\n";
		textTop += "\t\t\tImage.style.height = parseInt(NewH);\n";
		textTop += "\t\t\tif (NewH &gt; HolderH){\n";
		textTop += "\t\t\t\tImage.style.height = HolderH;\n";
		textTop += "\t\t\t\tvar NewW = (HolderH * (ImageW/ImageH));\n";
		textTop += "\t\t\t\tImage.style.width = parseInt(NewW);\n";
		textTop += "\t\t\t}\n";
		textTop += "\t\t}else if (ImageW &lt; HolderW){\n";
		textTop += "\t\t\tif (ImageH &gt; HolderH){\n";
		textTop += "\t\t\t\tImage.style.height = HolderH;\n";
		textTop += "\t\t\t\tvar NewW = (HolderH * (ImageW/ImageH));\n";
		textTop += "\t\t\t\tImage.style.width = parseInt(NewW);\n";
		textTop += "\t\t\t}\n";
		textTop += "\t\t}\n";
		textTop += "\t\treorderSignature();\n";
		textTop += "\t}\n";
		textTop += "}\n";
		textTop += "&lt;/script&gt;\n\n";
	}
	
	//relayer background images and signatures to bottom	
	if (document.getElementById('AddSignature').checked){
		textTop += "&lt;script type=&quot;text/javascript&quot;&gt;\n";
		textTop += "function reorderSignature(){\n";
		textTop += "\tdocument.getElementById(&quot;BGImage&quot;).style.zIndex = &quot;-10&quot;;\n";
	}
		
	if (document.getElementById('AutoSign').checked){
		textTop += "\tdocument.getElementById(&quot;SignatureHolder&quot;).style.zIndex = &quot;-9&quot;;\n";
		textTop += "\tdocument.getElementById(&quot;SignatureImage&quot;).style.zIndex = &quot;-8&quot;;\n";
	}
	
	if (document.getElementById('ScriptelSign').checked || document.getElementById('FreehandSign').checked){
		for (j=0; (j < DrawData.length); j++){
			var RedrawParameter = DrawData[j].split("|");
			if (RedrawParameter[0] == scriptelSigBox || RedrawParameter[0] == freehandSigBox) {
				var divId = RedrawParameter[5];
				if (RedrawParameter[0] == freehandSigBox) {
					textTop +=  "\tdocument.getElementById(&quot;" + divId + "-preview&quot;).style.zIndex = &quot;-7&quot;;\n";
				}
				textTop += "\tdocument.getElementById(&quot;" + divId + "&quot;).style.zIndex = &quot;-6&quot;;\n";
			}
		}
	}
	
	if (document.getElementById('AddSignature').checked){
		textTop += "}\n";
		textTop += "&lt;/script&gt;\n\n";
	}
	<% } %>
	//</head>
	textTop += "&lt;/head&gt;\n\n";
	//<body>
	textTop += "&lt;body";
	textTop += " onload=&quot;";
	//auto check gender boxes
	if (document.getElementById('preCheckGender').checked){
		textTop += "checkGender();";
	}
	<% if (!OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>
	//auto load signature image, default to 'current_user'
	if (document.getElementById('AutoSign').checked){
		textTop += "reloadSignature();";
	}
	//if freehand signature, initialize mouse scripts and reload previous freehand signature
	if (document.getElementById('FreehandSign').checked ){
		textTop += "init();ReloadImage();";
	}
	<% } %>
	textTop += "&quot;&gt;\n";
	//<img> background image
	textTop += "&lt;img id=&quot;BGImage&quot; src=&quot;$%7Boscar_image_path%7D";
	textTop += document.getElementById('imageName').value;
	textTop += "&quot; style=&quot;position: absolute; left: 0px; top: 0px; width:";
	textTop += BGWidth;
	textTop += "px&quot;&gt;\n";
	//overlay canvas the size of background iamge for drawing in checkmarks
	if(document.getElementById('DefaultCheckmark').checked){
		textTop += "&lt;div id=&quot;chkCanvas&quot; style=&quot;position:absolute; left:0px; top:0px; width:";
		textTop += BGWidth;
		textTop += "; height:";
		textTop += BGHeight;
		textTop += ";&quot; onmouseover=&quot;putInBack();&quot;&gt;&lt;/div&gt;\n\n";
	}
	//<form>
	textTop +="&lt;form method=&quot;post&quot; action=&quot;&quot; name=&quot;FormName&quot; id=&quot;FormName&quot; &gt;\n\n";
}

function GetTextMiddle(P){
	var InputType = P[0];
	if (InputType == "Text"){
		var x0 = parseInt(P[1]);
		var y0 = parseInt(P[2]);
		var width = parseInt(P[3]);
		var height = parseInt(P[4]);
		var inputName = P[5];
		var fontFamily = P[6];
		var fontStyle = P[7];
		var fontWeight = P[8];
		var fontSize = P[9];
		var textAlign = P[10];
		var bgColor = P[11];
		var oscarDB = P[12];
		var inputValue = P[13];
		m = "&lt;input name=&quot;";
		m += inputName;
		m += "&quot; id=&quot;";
		m += inputName;
		m += "&quot; type=&quot;text&quot; class=&quot;noborder&quot; style=&quot;position:absolute; left:";
		m += x0;
		m += "px; top:";
		m += y0;
		m += "px; width:";
		m += width;
		m += "px; height:";
		m += height;
		m += "px; font-family:";
		m += fontFamily;
		m += "; font-style:";
		m += fontStyle;
		m += "; font-weight:";
		m += fontWeight;
		m += "; font-size:";
		m += fontSize;
		m += "px; text-align:";
		m += textAlign;
		m += "; background-color:";
		m += bgColor;
		m += ";&quot; ";
		if (oscarDB){
			m += " oscarDB=";
			m += oscarDB;
		}else if (!oscarDB){
			m += "value=&quot;";
			m += inputValue;
			m += "&quot;";
		}
		m += "&gt;\n";

	} else if (InputType == "Textbox"){
		var x0 = parseInt(P[1]);
		var y0 = parseInt(P[2]);
		var width = parseInt(P[3]);
		var height = parseInt(P[4]);
		var inputName = P[5];
		var fontFamily = P[6];
		var fontStyle = P[7];
		var fontWeight = P[8];
		var fontSize = P[9];
		var textAlign = P[10];
		var bgColor = P[11];
		var oscarDB = P[12];
		var inputValue = P[13];
		m = "&lt;textarea name=&quot;";
		m += inputName;
		m += "&quot; id=&quot;";
		m += inputName;
		m += "&quot; class=&quot;noborder&quot; style=&quot;position:absolute; left:";
		m += x0;
		m += "px; top:";
		m += y0;
		m += "px; width:";
		m += width;
		m += "px; height:";
		m += height;
		m += "px; font-family:";
		m += fontFamily;
		m += "; font-style:";
		m += fontStyle;
		m += "; font-weight:";
		m += fontWeight;
		m += "; font-size:";
		m += fontSize;
		m += "px; text-align:";
		m += textAlign;
		m += "; background-color:";
		m += bgColor;
		m += ";&quot; ";
		if (oscarDB){
			m += " oscarDB=";
			m += oscarDB;
		}
		m += "&gt;";
		if (!oscarDB) {
			m += inputValue;
		}
		m += "&lt;/textarea&gt;\n";

	} else if (InputType == "Checkbox"){
		var x = parseInt(P[1]);
		var y = parseInt(P[2]);
		var inputName = P[3];
		var preCheck = P[4];
		m = "&lt;input name=&quot;";
		m += inputName;
		m += "&quot; id=&quot;";
		m += inputName;
		m += "&quot; type=&quot;checkbox&quot;";
		if (document.getElementById('ScaleCheckmark').checked){
			m += " class=&quot;largerCheckbox&quot;";
		}
		m += " style=&quot;position:absolute; left:";
		var a = parseInt(x - CheckboxOffset);
		m += a;
		m += "px; top:";
		var b = parseInt(y - CheckboxOffset);
		m += b;
		m += "px; &quot;";
		if (preCheck == 'true'){
			m += " checked";
		}
		m += "&gt;\n";
	} else if (InputType == scriptelSigBox) {
		// organize the scripts for scriptel signature
		var x0 = parseInt(P[1]);
		var y0 = parseInt(P[2]);
		var width = parseInt(P[3]);
		var height = parseInt(P[4]);
		var inputName = P[5];
		
		//<input type="hidden" name="SignCanvas-TempData" id="SignCanvas-TempData">
		/*
		m = "&lt;input type=&quot;hidden&quot; name=&quot;";
		m += inputName + "-TempData&quot; id=&quot;" + inputName + "-TempData&quot; ";
		m += "/&gt;\n";
		*/
		
		//<input type="hidden" name="SignCanvas-DrawData" id="SignCanvas-DrawData">
		/*
		m += "&lt;input type=&quot;hidden&quot; name=&quot;";
		m += inputName + "-DrawData&quot; id=&quot;" + inputName + "-DrawData&quot; ";
		m += "/&gt;\n";
		*/
		
		//<input type="hidden" name="SignCanvas-SubmitData" id="SignCanvas-SubmitData">
		/*
		m += "&lt;input type=&quot;hidden&quot; name=&quot;";
		m += inputName + "-SubmitData&quot; id=&quot;" + inputName + "-SubmitData&quot; ";
		m += "/&gt;\n";
		*/
		
		//<img id="SignCanvas-img" name="SignCanvas-img" src="" style="position:absolute; display:none; lefx:141px; top:277px; width:100px; height:20px;" onclick=""/>
		m = "&lt;img id=&quot;" + inputName + "-img&quot; ";
		m += "name=&quot;" + inputName + "-img&quot; ";
		m += "src=&quot;&quot; ";
		m += "style=&quot;position:absolute; display:none; left:" + x0 + "px; top:" + y0 + "px; width:" + width + "px; height:" + height + "px;&quot; ";
		m += "onclick=&quot;showScriptelInputBox(this);&quot;"
		m += "/&gt;\n";
		
		// <input type="hidden" name="SignCanvas-imgSavedId" id="SignCanvas-imgSavedId" value="0" />
		m += "&lt;input type=&quot;hidden&quot; name=&quot;" + inputName + "-imgSavedId&quot; ";
		m += "id=&quot;" + inputName + "-imgSavedId&quot; ";
		m += "value=&quot;0&quot;"
		m += "/&gt;\n";
		
		//<input type="text" name="SignCanvas-signature" id="SignCanvas-signature" style="position:absolute; display:inline; top:277px; left:141px;
	//	 height:20px" onkeyup="onkeyuphdlr(this);">
		m += "&lt;input type=&quot;text&quot; name=&quot;" + inputName + "-signature&quot; ";
		m += "id=&quot;" + inputName + "-signature&quot; ";
		m += "style=&quot;position:absolute; display:inline; left:" + x0 + "px; top:" + (y0 + height - 20) + "px; width:" + width + "px; height:20px; &quot; ";
		m += "onkeyup=&quot;onkeyuphdlr(this);&quot; ";
		m += "/&gt;\n";
	
	//	 <input type="button" name="SignCanvas-ClearSignature" id="SignCanvas-ClearSignature" style="position:absolute; display:inline; top:277px; left:241px; height:20px" value="Clear" onclick="Clear(this);">
		m += "&lt;input type=&quot;button&quot; ";
		m += "name=&quot;" + inputName + "-ClearSignature&quot; ";
		m += "id=&quot;" + inputName + "-ClearSignature&quot; ";
		m += "style=&quot;position:absolute; display:inline; left:" + (x0 + width + 2) + "px; top:" + (y0 + height - 20) + "px; height:20px; &quot; ";
		m += "value=&quot;Clear&quot; ";
		m += "onclick=&quot;clearScriptelSignature(this);&quot; ";
		m += "/&gt;\n";
		
		//<input type="button" name="ScriptelSignatureBox2-showSig" id="ScriptelSignatureBox2-showSig" style="position:absolute; display:none; left:471px; top:701px; height:20px; " value="Show Signauture" onclick="showScriptelSignature(this);" />
		m += "&lt;input type=&quot;button&quot; ";
		m += "name=&quot;" + inputName + "-showSig&quot; ";
		m += "id=&quot;" + inputName + "-showSig&quot; ";
		m += "style=&quot;position:absolute; display:none; left:" + (x0 + width + 62) + "px; top:" + (y0 + height - 20) + "px; height:20px; &quot; ";
		m += "value=&quot;Show Signature&quot; ";
		m += "onclick=&quot;showScriptelSignature(this);&quot; ";
		m += "/&gt;\n";
		
	//	 <div type="ScriptelSignatureBox" id="SignCanvas" class="sig" index="1" style="position:absolute; left:71px; top:177px; width:500px; height:100px"
	//	 onmouseover="SetDrawOn(this); "
	//	 onmouseout="SetDrawOff(this); "
	//	 onmousedown="SetMouseDown(this);SetStart(this);"
	//	 onmouseup="SetMouseUp(this); DrawMarker(this);"
	//	 onmousemove="DrawPreview(this);"> 
	// <canvas hidden="" width="500" height="100" 
	// id="ScriptelSignatureBox2-canvas" cursor="pointer" 
	// style="position:absolute;top:0;left:0;"></canvas>
	//	</div>
		var index = getSignatureIndex(InputType, inputName);
		m += "&lt;div type=&quot;" + scriptelSigBox + "&quot; id=&quot;" + inputName + "&quot; ";
		m += "class=&quot;sig&quot; ";
		m += "index=&quot;" + index + "&quot; ";
		m += "style=&quot;position:absolute; width:0px; height:0px; &quot;\n";
		m += "&gt;\n";
		//m += "&lt;canvas id=&quot;" + inputName + "-canvas&quot; ";
		//m += "hidden=&quot;true&quot; ";
		//m += "style=&quot;position:absolute; top:0px; left:0px; width:500px; height:100px;&quot; ";
		//m += "cursor=&quot;pointer&quot; &gt;\n";
		//m += "&lt/canvas&gt;\n"
		m += "&lt;/div&gt;\n"
	} else if (InputType == freehandSigBox) {
		var x0 = parseInt(P[1]);
		var y0 = parseInt(P[2]);
		var width = parseInt(P[3]);
		var height = parseInt(P[4]);
		var inputName = P[5];
		
		//<input type="hidden" name="SignCanvas-TempData" id="SignCanvas-TempData">
		m = "&lt;input type=&quot;hidden&quot; name=&quot;";
		m += inputName + "-TempData&quot; id=&quot;" + inputName + "-TempData&quot; ";
		m += "/&gt;\n";
		
		//<input type="hidden" name="SignCanvas-DrawData" id="SignCanvas-DrawData">
		m += "&lt;input type=&quot;hidden&quot; name=&quot;";
		m += inputName + "-DrawData&quot; id=&quot;" + inputName + "-DrawData&quot; ";
		m += "/&gt;\n";
		
		//<input type="hidden" name="SignCanvas-SubmitData" id="SignCanvas-SubmitData">
		m += "&lt;input type=&quot;hidden&quot; name=&quot;";
		m += inputName + "-SubmitData&quot; id=&quot;" + inputName + "-SubmitData&quot; ";
		m += "/&gt;\n";
		
		// <input type="button" name="SignCanvas-ClearSignature" id="SignCanvas-ClearSignature" 
		// style="position:absolute; display:inline; top:277px; left:241px; height:20px" value="Clear" 
		// onclick="Clear(this);" onmouseover="show(this.id);" onmouseout="hide(this.id);" />
		m += "&lt;input type=&quot;button&quot; ";
		m += "name=&quot;" + inputName + "-ClearSignature&quot; ";
		m += "id=&quot;" + inputName + "-ClearSignature&quot; ";
		m += "style=&quot;position:absolute; display:none; left:" + (x0 + width) + "px; top:" + y0 + "px; height:" + height + "px; &quot; ";
		m += "value=&quot;Clear&quot; ";
		m += "onclick=&quot;Clear(this);&quot; ";
		m += "onmouseover=&quot;show(this.id);&quot; ";
		m += "onmouseout=&quot;hide(this.id);&quot; ";
		m += "/&gt;\n";
		
		// <div id="preview" class="DoNotPrint" style="position:absolute; left:78px; top:129px; width:151px; height:87px; background-color:grey;opacity:0.5;filter:alpha(opacity=50);"></div>
		
		m += "&lt;div id=&quot;" + inputName + "-preview&quot; ";
		m += "class=&quot;DoNotPrint&quot; ";
		m += "style=&quot;position:absolute; left:" + x0 + "px; top:" + y0 + "px; width:" + width + "px; height:" + height + "px; "; 
		m += "background-color:grey;opacity:0.5;filter:alpha(opacity=50);&quot; class=&quot;DoNotPrint&quot;&gt;\n"; 
		m += "&lt;/div&gt;\n";
		
		// <div type="FreehandSignatureBox" index="1" id="SignCanvas" onmousemove="DrawPreview();" onmouseup="SetMouseUp(); DrawMarker();" 
		// onmousedown="SetMouseDown();SetStart();" 
		// onmouseout="SetDrawOff(); hide('ClearSignature');" 
		// onmouseover="SetDrawOn(); show('ClearSignature');" 
		// style="position:absolute; left:78px; top:129px; width:151px; height:87px"> </div>
		var index = getSignatureIndex(InputType, inputName);
		m += "&lt;div type=&quot;" + freehandSigBox + "&quot; ";
		m += "index=&quot;" + index + "&quot; ";
		m += "id=&quot;" + inputName + "&quot; ";
		m += "onmousemove=&quot;DrawPreview(this);&quot; ";
		m += "onmouseup=&quot;SetMouseUp(this);DrawMarker(this);&quot; ";
		m += "onmousedown=&quot;SetMouseDown(this);SetStart(this);&quot; ";
		m += "onmouseout=&quot;SetDrawOff(this); hide(&apos;" + inputName + "-ClearSignature&apos;);&quot; ";
		m += "onmouseover=&quot;SetDrawOn(this); show(&apos;" + inputName + "-ClearSignature&apos;);&quot; ";
		m += "style=&quot;position:absolute; left:" + x0 + "px; top:" + y0 + "px; width:" + width + "px; height:" + height + "px;&quot;&gt;\n";
		m += "&lt;/div&gt;\n";
	}

	textMiddle += m;
	textMiddle += "\n\n";
}

function GetTextBottom(){
	//gender checkboxes
	if (document.getElementById('preCheckGender').checked){
		textBottom += "&lt;input name=&quot;PatientGender&quot; id=&quot;PatientGender&quot; type=&quot;hidden&quot; oscarDB=sex&gt;\n";
		textBottom += "&lt;input name=&quot;Male&quot; id=&quot;Male&quot; type=&quot;checkbox&quot; class=&quot;noborder&quot; style=&quot;position:absolute; left: ";
		textBottom += parseInt(MTopLeftX - CheckboxOffset);
		textBottom += "px; top: ";
		textBottom += parseInt(MTopLeftY - CheckboxOffset);
		textBottom += "px&quot;&gt;\n";
		textBottom += "&lt;input name=&quot;Female&quot; id=&quot;Female&quot; type=&quot;checkbox&quot; class=&quot;noborder&quot; style=&quot;position:absolute; left: ";
		textBottom += parseInt(FTopLeftX - CheckboxOffset);
		textBottom += "px; top: ";
		textBottom += parseInt(FTopLeftY - CheckboxOffset);
		textBottom += "px&quot;&gt;\n\n";
	}
	<% if (!OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>
	//auto load signature images
	if (document.getElementById('AutoSign').checked){
		textBottom +="&lt;input type=&quot;hidden&quot; name=&quot;DoctorName&quot; id=&quot;DoctorName&quot; oscarDB=doctor&gt;\n";
		textBottom +="&lt;input type=&quot;hidden&quot; name=&quot;CurrentUserName&quot; id=&quot;CurrentUserName&quot; oscarDB=current_user&gt;\n";
		textBottom +="&lt;input type=&quot;hidden&quot; name=&quot;SubmittedBy&quot; id=&quot;SubmittedBy&quot;&gt;\n";
		textBottom +="&lt;div name=&quot;SignatureHolder&quot; id=&quot;SignatureHolder&quot; style=&quot;position:absolute; left:";
		textBottom += SignatureHolderX;
		textBottom += "px; top:";
		textBottom += SignatureHolderY;
		textBottom += "px; width:";
		textBottom += SignatureHolderW;
		textBottom += "px; height:";
		textBottom += SignatureHolderH;
		textBottom += "&quot; onmouseover=&quot;show(&apos;SignaturePicker&apos;);&quot; onmouseout=&quot;hide(&apos;SignaturePicker&apos;);&quot;&gt;\n";
		textBottom += "&lt;/div&gt;\n";
		textBottom += "&lt;div class=&quot;DoNotPrint&quot; name=&quot;SignaturePicker&quot; id=&quot;SignaturePicker&quot; style=&quot;position:absolute; background-color:#dddddd; left:";
		textBottom += SignatureHolderX;
		textBottom += "px; top:";
		textBottom += SignatureHolderY;
		textBottom += "px; height:";
		textBottom += SignatureHolderH;
		textBottom += "; display:none;&quot; onmouseover=&quot;show(this.id)&quot; onmouseout=&quot;hide(this.id)&quot;&gt;\n";
		textBottom += "	&lt;span style=&quot;font-family:sans-serif; font-size:12px; font-weight:bold&quot;&gt;\n";
		textBottom += "		Signature:&lt;br&gt;\n";
		textBottom += "		&lt;input type=&quot;radio&quot; name=&quot;SignBy&quot; id=&quot;SignDoctor&quot; value=&quot;doctor&quot; onclick=&quot;SignForm(this.value);&quot; onmouseout=&quot;resizeSignature();&quot;&gt;Patient's Doctor\n";
		textBottom += "		&lt;input type=&quot;radio&quot; name=&quot;SignBy&quot; id=&quot;SignCurrentUser&quot; value=&quot;current_user&quot; onclick=&quot;SignForm(this.value);&quot; onmouseout=&quot;resizeSignature();&quot;&gt;Current User\n";
		textBottom += "		&lt;input type=&quot;radio&quot; name=&quot;SignBy&quot; id=&quot;SignNone&quot; value=&quot;none&quot; onclick=&quot;SignForm(this.value);&quot;&gt;None\n";
		textBottom += "	&lt;/span&gt;\n";
		textBottom += "&lt;/div&gt;\n\n";
	}

	//Freehand Signature
	//if (document.getElementById('FreehandSign').checked){
		/*
		textBottom += "&lt;input type=&quot;hidden&quot; name=&quot;SignCanvas-TempData&quot; id=&quot;SignCanvas-TempData&quot;&gt;\n";
		textBottom += "&lt;input type=&quot;hidden&quot; name=&quot;SignCanvas-DrawData&quot; id=&quot;SignCanvas-DrawData&quot;&gt;\n";
		textBottom += "&lt;input type=&quot;hidden&quot; name=&quot;SignCanvas-SubmitData&quot; id=&quot;SignCanvas-SubmitData&quot;&gt;\n";
		textBottom += "&lt;input type=&quot;button&quot; class=&quot;sig&quot; name=&quot;SignCanvas-ClearSignature&quot; id=&quot;SignCanvas-ClearSignature&quot; style=&quot;position:absolute; display:inline; top:";
		textBottom += SignatureHolderY+ 100;
		textBottom += "px; left:";
		textBottom += SignatureHolderX;
		textBottom += "px; height:";
		textBottom += 20;
		textBottom += "px&quot; value=&quot;Clear&quot; ";
		textBottom += "onclick=&quot;Clear(this);&quot;&gt;\n";
		textBottom += "&lt;input type=&quot;text&quot; name=&quot;SignCanvas-signature&quot; id=&quot;SignCanvas-signature&quot; style=&quot;position:absolute; display:inline; top:";
		textBottom += SignatureHolderY+ 100;
		textBottom += "px; left:";
		textBottom += SignatureHolderX + 70;
		textBottom += "px; height:";
		textBottom += 20;
		textBottom += "px&quot; onkeyup=&quot;onkeyuphdlr(this);&quot;&gt;\n";
		
		textBottom += "&lt;div id=&quot;SignCanvas&quot; class=&quot;sig&quot; style=&quot;position:absolute; left:";
		textBottom += SignatureHolderX;
		textBottom += "px; top:";
		textBottom += SignatureHolderY;
		textBottom += "px; width:";
		textBottom += SignatureHolderW;
		textBottom += "px; height:";
		textBottom += SignatureHolderH;
		textBottom += "px&quot;\n";
		textBottom += " onmouseover=&quot;SetDrawOn(this); &quot;\n";
		textBottom += " onmouseout=&quot;SetDrawOff(this); &quot;\n";
		textBottom += " onmousedown=&quot;SetMouseDown(this);SetStart(this);&quot;\n";
		textBottom += " onmouseup=&quot;SetMouseUp(this); DrawMarker(this);&quot;\n";
		textBottom += " onmousemove=&quot;DrawPreview(this);&quot;&gt; \n";
		textBottom += "&lt;/div&gt;\n";
		*/
	
		/*textBottom += "&lt;input type=&quot;hidden&quot; name=&quot;TempData&quot; id=&quot;TempData&quot;&gt;\n";
		textBottom += "&lt;input type=&quot;hidden&quot; name=&quot;DrawData&quot; id=&quot;DrawData&quot;&gt;\n";
		textBottom += "&lt;input type=&quot;hidden&quot; name=&quot;SubmitData&quot; id=&quot;SubmitData&quot;&gt;\n";

		textBottom += "&lt;input type=&quot;button&quot; name=&quot;ClearSignature&quot; id=&quot;ClearSignature&quot; style=&quot;position:absolute; display:none; top:";
		textBottom += SignatureHolderY;
		textBottom += "px; left:";
		textBottom += SignatureHolderX + SignatureHolderW;
		textBottom += "px; height:";
		textBottom += SignatureHolderH;
		textBottom += "px&quot; value=&quot;Clear Signature&quot; ";
		textBottom += "\tonmouseover=&quot;show(this.id);&quot; onmouseout=&quot;hide(this.id);&quot; onclick=&quot;Clear();&quot;&gt;\n";

		textBottom += "&lt;div id=&quot;preview&quot; style=&quot;position:absolute; left:";
		textBottom += SignatureHolderX;
		textBottom += "px; top:";
		textBottom += SignatureHolderY;
		textBottom += "px; width:";
		textBottom += SignatureHolderW;
		textBottom += "px; height:";
		textBottom += SignatureHolderH;
		textBottom += "px; background-color:grey;opacity:0.5;filter:alpha(opacity=50);&quot; class=&quot;DoNotPrint&quot;&gt;&lt;/div&gt;\n";
		textBottom += "&lt;div id=&quot;SignCanvas&quot; style=&quot;position:absolute; left:";
		textBottom += SignatureHolderX;
		textBottom += "px; top:";
		textBottom += SignatureHolderY;
		textBottom += "px; width:";
		textBottom += SignatureHolderW;
		textBottom += "px; height:";
		textBottom += SignatureHolderH;
		textBottom += "px&quot;\n";
		textBottom += "		onmouseover=&quot;SetDrawOn(); show(&apos;ClearSignature&apos;);&quot;\n";
		textBottom += "		onmouseout=&quot;SetDrawOff(); hide(&apos;ClearSignature&apos;);&quot;\n";
		textBottom += "		onmousedown=&quot;SetMouseDown();SetStart();&quot;\n";
		textBottom += "		onmouseup=&quot;SetMouseUp();  DrawMarker();&quot;\n";
		textBottom += "		onmousemove=&quot;DrawPreview();&quot;&gt; \n";
		textBottom += "&lt;/div&gt;\n";
		*/
	//}	
	<% } %>

	//bottom submit boxes
	textBottom += "\n\n &lt;div class=&quot;DoNotPrint&quot; style=&quot;position: absolute; top:";
	textBottom += BGHeight;
	textBottom += "px; left:0px;&quot; id=&quot;BottomButtons&quot; &gt;\n";
	textBottom += "\t &lt;table&gt;&lt;tr&gt;&lt;td&gt;\n";
	textBottom += "\t\t Subject: &lt;input name=&quot;subject&quot; size=&quot;40&quot; type=&quot;text&quot;&gt; \n";
	textBottom += "\t\t	&lt;input value=&quot;Submit&quot; name=&quot;SubmitButton&quot; id=&quot;SubmitButton&quot; type=&quot;submit&quot; onclick=&quot;";
	<% if (!OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>
	if (document.getElementById('FreehandSign').checked || document.getElementById('ScriptelSign').checked){
		textBottom += "SubmitImage();";
	}
	<% } %>
	textBottom += " releaseDirtyFlag();&quot;&gt; \n";
	textBottom += "\t\t\t&lt;input value=&quot;Reset&quot; name=&quot;ResetButton&quot; id=&quot;ResetButton&quot; type=&quot;reset&quot;&gt; \n";
	textBottom += "\t\t	&lt;input value=&quot;Print&quot; name=&quot;PrintButton&quot; id=&quot;PrintButton&quot; type=&quot;button&quot; onclick=&quot;formPrint();&quot;&gt; \n";
	textBottom += "\t\t	&lt;input value=&quot;Print &amp; Submit&quot; name=&quot;PrintSubmitButton&quot; id=&quot;PrintSubmitButton&quot; type=&quot;button&quot; onclick=&quot;formPrint();releaseDirtyFlag();setTimeout(&apos;SubmitButton.click()&apos;,1000);&quot;&gt; \n";
	if(document.getElementById('DefaultCheckmark').checked){
		textBottom += "\t\t	&lt;input name=&quot;DrawCheckmark&quot; id=&quot;DrawCheckmark&quot; type=&quot;checkbox&quot; checked&gt;";
		textBottom += "&lt;span style=&quot;font-family:sans-serif; font-size:12px;&quot;&gt;Draw Checkmarks&lt;/span&gt; \n";
	}
	textBottom += "\t &lt;/td&gt;&lt;/tr&gt;&lt;/table&gt;\n";
	textBottom += " &lt;/div&gt;\n &lt;/form&gt;\n\n";

	//Bottom Graphic Scripts for drawing in checkmarks
	if (document.getElementById('DefaultCheckmark').checked){
		textBottom += "&lt;script type=&quot;text/javascript&quot;&gt;\n";
		textBottom += "&lt;!-- Drawing in checkmarks --&gt;\n";
		textBottom += "var chkcnv = document.getElementById(&quot;chkCanvas&quot;);\n";
		textBottom += "var chkjg = new jsGraphics(chkcnv);\n";
		textBottom += "var chkcnvLeft = parseInt(chkcnv.style.left);\n";
		textBottom += "var chkcnvTop = parseInt(chkcnv.style.top);\n";
		textBottom += "chkjg.setPrintable(true);\n";

		textBottom += "function drawCheckmark(x,y){\n";
		textBottom += "var offset = 6;\n";
		textBottom += "var x = parseInt(x) + offset;\n";
		textBottom += "var y = parseInt(y) + offset;\n";
		textBottom += "chkjg.setColor(&quot;black&quot;);\n";
		textBottom += "chkjg.setStroke(3);\n";
		textBottom += "\t	// draws checkmark\n";
		textBottom += "\t	var x1 = x;\n";
		textBottom += "\t	var y1 = y+4;\n";
		textBottom += "\t	var x2 = x1 + 3;\n";
		textBottom += "\t	var y2 = y1 + 4;\n";
		textBottom += "\t	var x3 = x2 + 4;\n";
		textBottom += "\t	var y3 = y2 - 12;\n";
		textBottom += "\t	chkjg.drawLine(x1,y1,x2,y2);\n";
		textBottom += "\t	chkjg.drawLine(x2,y2,x3,y3);\n";
		textBottom += "\t	chkjg.paint();\n";
		textBottom += "}\n";
		textBottom += "function replaceCheckmarks(){\n";
		textBottom += "var f = document.getElementById(&quot;FormName&quot;);\n";
		textBottom += "	\t for (var i=0;i&lt;f.length;i++){\n";
		textBottom += "	\t\t	if ((f.elements[i].type == &quot;checkbox&quot;) &amp;&amp; (f.elements[i].checked)){\n";
		textBottom += "	\t\t		var a = f.elements[i].style.left;\n";
		textBottom += "	\t\t		var b = f.elements[i].style.top;\n";
		textBottom += "	\t\t		drawCheckmark(a,b);\n";
		textBottom += "	\t\t	}\n";
		textBottom += "	\t }\n";
		textBottom += "}\n";
		textBottom += "function printCheckboxes(){\n";
		textBottom += "\t	putInFront();\n";
		textBottom += "\t	replaceCheckmarks();\n";
		textBottom += "\t	window.print();\n";
		textBottom += "}\n";
		textBottom += "function putInFront(){\n";
		textBottom += "\t	chkcnv.style.zIndex = &quot;999999&quot;;	\n";
		textBottom += "}\n";
		textBottom += "function putInBack(){\n";
		textBottom += "\t	chkcnv.style.zIndex = &quot;-999999&quot;;	\n";
		textBottom += "}\n";
		textBottom += "&lt;/script&gt;\n";
	}

	<% if (!OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>
	
	if (document.getElementById('ScriptelSign').checked || document.getElementById('FreehandSign').checked) {
		textBottom += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_javascript_path%7Djquery/jquery-1.4.2.js&quot;&gt;&lt;/script&gt;\n";
		
		textBottom += "&lt;script type=&quot;text/javascript&quot;&gt;\n";
		
		/*
		function getSignatureCount(type) {
			return jQuery("div[type='" + type + "']").length;
		}
		*/
		textBottom += "\tfunction getSignatureCount(type) {\n";
		textBottom += "\t\treturn jQuery(&quot;div[type=\\&quot;&quot; + type + &quot;\\&quot;]&quot;).length;\n";
		textBottom += "\t}\n\n";
		
		textBottom += "&lt;/script&gt;\n\n";
	}
	
	if (document.getElementById('ScriptelSign').checked){
		
		// add a div node to store the iframe page used to save signature picture
		textBottom += "&lt;div id=&quot;signatureInput&quot;&gt; &lt;/div&gt;\n";
		
		textBottom += "&lt;!-- scriptel signature scripts --&gt;\n";
	    textBottom += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_javascript_path%7Deforms/signatureControl.jsp&quot;&gt;&lt;/script&gt;\n";
	    textBottom += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_javascript_path%7Dsignature.js&quot;&gt;&lt;/script&gt;\n";
		textBottom += "&lt;script type=&quot;text/javascript&quot;&gt;\n";
		
		textBottom += "\tvar size = getSignatureCount(&quot;" + scriptelSigBox + "&quot;);\n";
		textBottom += "\tvar cnv = new Array(size);\n";
		textBottom += "\tvar jg = new Array(size);\n";
		textBottom += "\tvar cnvLeft = new Array(size);\n";
		textBottom += "\tvar cnvTop = new Array(size);\n";
		textBottom += "\tvar contextPath = &quot;&quot;;\n";
		
		/*
		function gup(name, url) {
			if (url == null) {
				url = window.location.href;
			}
			name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
			var regexS = "[\\?&]"+name+"=([^&#]*)";
			var regex = new RegExp(regexS);
			var results = regex.exec(url);
			if (results == null) {
				return "";
			} else {
				return results[1];
			}
		}
		*/
		textBottom += "\tfunction gup(name, url) %7B\n";
		textBottom += "\t\tif (url == null) %7B\n";
		textBottom += "\t\t\turl = window.location.href;\n";
		textBottom += "\t\t}\n";
		textBottom += "\t\tname = name.replace(/[\\[]/,&quot;\\\\\\[&quot;).replace(/[\\]]/,&quot;\\\\\\]&quot;);\n";
		textBottom += "\t\tvar regexS = &quot;[\\\\\?&]&quot;+name+&quot;=([^&#]*)&quot;;\n";
		textBottom += "\t\tvar regex = new RegExp(regexS);\n";
		textBottom += "\t\tvar results = regex.exec(url);\n";
		textBottom += "\t\tif (results == null) %7B\n";
		textBottom += "\t\t\treturn &quot;&quot;;\n";
		textBottom += "\t\t} else {\n";
		textBottom += "\t\t\treturn results[1];\n";
		textBottom += "\t\t\}\n";
		textBottom += "\t}\n";
		
		/*
		$(function() {
			$("div.sig").scriptelSigCap();
			//$("input.sig").click(function() {
			//	window.console.log(this.id)
			//	var divId = getElementIdPrefix(this);
			//	$("#"+ divId).scriptelSigCap("clear");
			//	$("#"+ divId).val("");
			//	return false;
			//});
			
			jQuery("div[type='ScriptelSignatureBox']").each(function(){
				var index = this.getAttribute("index");
				if (index != undefined && index != null) {
					cnv[index - 1] = this;
					if (this != null) {
						jg[index - 1] = new jsGraphics(this);
						cnvLeft[index - 1] = parseInt(cnv[index - 1].style.left);
						cnvTop[index - 1] = parseInt(cnv[index - 1].style.top);
						jg[index - 1].setPrintable(true);
					}
				}
			});

			var demographicNo = gup("demographic_no");
			if (demographicNo == "") {
				demographicNo = gup("efmdemographic_no", jQuery("form").attr("action"));
			}
			if (typeof signatureControl != "undefined") {
				signatureControl.initialize({
					sigHTML:"../signature_pad/tabletSignature.jsp?inWindow=true&saveToDB=true&demographicNo=",
					demographicNo:demographicNo,
					refreshImage: function (e) {
						var html = "<img src=&apos;"+e.storedImageUrl+"&r="+ Math.floor(Math.random()*1001) +"&apos;></img>";
						doHtml(html);
					},
					signatureInput: "#signatureInput"
				});
			}
	
			jQuery("#signatureInput").attr("hidden", "true");
			jQuery("canvas").attr("hidden", "true");
		});
		*/
		textBottom += "\t$(function() {\n";
		textBottom += "\t\t$(&quot;div.sig&quot;).scriptelSigCap();\n";
		//textBottom += "\t\t$(&quot;input.sig&quot;).click(function() {\n";
		//textBottom += "\t\t\twindow.console.log(this.id)\n";
		//textBottom += "\t\t\tvar divId = getElementIdPrefix(this);\n";
		//textBottom += "\t\t\t$(&quot;#&quot;+ divId).scriptelSigCap(&quot;clear&quot;);\n";
		//textBottom += "\t\t\t$(&quot;#&quot;+ divId).val(&quot;&quot;);\n";
		//textBottom += "\t\t\treturn false;\n";
		//textBottom += "\t\t});\n\n";
		
		textBottom += "\t\tjQuery(&quot;div[type=\\&quot;" + scriptelSigBox + "\\&quot;]&quot;).each(function(){\n";
		textBottom += "\t\t\tvar index = this.getAttribute(&quot;index&quot;);\n";
		textBottom += "\t\t\tif (index != undefined && index != null) {\n";
		textBottom += "\t\t\t\tcnv[index - 1] = this;\n";
		textBottom += "\t\t\t\tif (cnv[index - 1] != null) {\n";
		textBottom += "\t\t\t\t\tjg[index - 1] = new jsGraphics(cnv[index - 1]);\n";
		textBottom += "\t\t\t\t\tcnvLeft[index - 1] = parseInt(cnv[index - 1].style.left);\n";
		textBottom += "\t\t\t\t\tcnvTop[index - 1] = parseInt(cnv[index - 1].style.top);\n";
		textBottom += "\t\t\t\t\tjg[index - 1].setPrintable(true);\n";
		textBottom += "\t\t\t\t}\n";
		textBottom += "\t\t\t}\n";
		textBottom += "\t\t});\n";
		
		textBottom += "\t\tvar demographicNo = gup(&quot;demographic_no&quot;);\n";
		textBottom += "\t\tif (demographicNo == &quot;&quot;) %7B\n";
		textBottom += "\t\t\tdemographicNo = gup(&quot;efmdemographic_no&quot;, jQuery(&quot;form&quot;).attr(&quot;action&quot;));\n";
		textBottom += "\t\t}\n";
		textBottom += "\t\tif (typeof signatureControl != &quot;undefined&quot;) %7B\n";
		textBottom += "\t\t\tsignatureControl.initialize({\n";
		textBottom += "\t\t\t\tsigHTML:&quot;../signature_pad/tabletSignature.jsp?inWindow=true&saveToDB=true&demographicNo=&quot;,\n";
		textBottom += "\t\t\t\tdemographicNo:demographicNo,\n";
		textBottom += "\t\t\t\trefreshImage: function (e) {\n";
		//textBottom += "\t\t\t\t\tvar html = &quot;&lt;img src=&apos;&quot;+e.storedImageUrl+&quot;&r=&quot;+ Math.floor(Math.random()*1001) +&quot;&apos;&gt;&lt;/img&gt;&quot;;\n";
		//textBottom += "\t\t\t\t\tdoHtml(html);\n";
		textBottom += "\t\t\t\t},\n";
		textBottom += "\t\t\t\tsignatureInput: &quot;#signatureInput&quot;\n";
		textBottom += "\t\t\t});\n";
		textBottom += "\t\t}\n\n";
		textBottom += "\t\tjQuery(&quot;#signatureInput&quot;).attr(&quot;hidden&quot;, &quot;true&quot;);\n";
		textBottom += "\t\tjQuery(&quot;canvas&quot;).attr(&quot;hidden&quot;, &quot;true&quot;);\n\n";
		textBottom += "\t\tloadSignaturePics();\n";
		textBottom += "\t});\n\n";
		
		textBottom += "\tfunction showSignature(which){\n";
		textBottom += "\t\tvar divId = getElementIdPrefix(which);\n";
		textBottom += "\t\t$(&quot;#&quot;+divId).scriptelSigCap(&quot;showScriptel&quot;, $(&quot;#&quot;+divId+&quot;-signature&quot;).val());\n";
		textBottom += "\t\treturn false;\n";
		textBottom += "\t}\n\n";
		
		//textBottom += "\tvar timerRefreshCanvas = null;\n";
		textBottom += "\tvar timerDetectInputStop = null;\n\n";
		
		/*function saveCanvas() {
			var divId = getElementIdPrefix(which);
			var canvas = document.getElementById(divId + "-canvas");
			var strDataURI = canvas.toDataURL("image/png");
			var subDoc = document.getElementById("signatureFrame").contentWindow.document;
			subDoc.getElementById("signatureImage").value = strDataURI;
	
			// Used to submit the form using Ajax.
			jQuery.ajax({
				type: "POST",
				url: contextPath + "/signature_pad/uploadSignature.jsp",
				data: jQuery("#signatureForm", subDoc).serialize(),
				success: function(data) {
					var savedId = jQuery(jQuery(data.trim())[0]).val();
					var img = document.getElementById(divId + "-img");
					if (img != null) {
						img.setAttribute("src", contextPath + "/imageRenderingServlet?source=signature_stored&digitalSignatureId=" + savedId + "&r=107");
						showScriptelSignature(which);
					}
				}
			});
			return false;
		} */
		textBottom += "\tfunction saveCanvas(which) {\n";
		textBottom += "\t\tvar divId = getElementIdPrefix(which);\n";
		textBottom += "\t\tvar canvas = document.getElementById(divId + &quot;-canvas&quot;);\n";
		textBottom += "\t\tvar strDataURI = canvas.toDataURL(&quot;image/png&quot;);\n";
		textBottom += "\t\tvar subDoc = document.getElementById(&quot;signatureFrame&quot;).contentWindow.document;\n";
		textBottom += "\t\tsubDoc.getElementById(&quot;signatureImage&quot;).value = strDataURI;\n\n";
		textBottom += "\t\t// Used to submit the form using Ajax.\n";
		textBottom += "\t\tjQuery.ajax({\n";
		textBottom += "\t\t\ttype: &quot;POST&quot;,\n";
		textBottom += "\t\t\turl: contextPath + &quot;/signature_pad/uploadSignature.jsp&quot;,\n";
		textBottom += "\t\t\tdata: jQuery(&quot;#signatureForm&quot;, subDoc).serialize(),\n";
		textBottom += "\t\t\tsuccess: function(data) {\n";
		textBottom += "\t\t\t\tvar savedId = jQuery(jQuery(data.trim())[0]).val();\n";
		textBottom += "\t\t\t\tvar img = document.getElementById(divId + &quot;-img&quot;);\n";
		textBottom += "\t\t\t\tif (img != null) {\n";
		textBottom += "\t\t\t\t\timg.setAttribute(&quot;src&quot;, contextPath + &quot;/imageRenderingServlet?source=signature_stored&digitalSignatureId=&quot; + savedId + &quot;&r=107&quot;);\n";
		textBottom += "\t\t\t\t\tdocument.getElementById(divId + &quot;-imgSavedId&quot;).value=savedId;\n";
		textBottom += "\t\t\t\t\tshowScriptelSignature(which);\n";
		textBottom += "\t\t\t\t}\n";
		textBottom += "\t\t\t}\n";
		textBottom += "\t\t});\n";
		textBottom += "\t\treturn false;\n";
		textBottom += "\t}\n\n";
		
		textBottom += "\tfunction stopInput(which){\n";
		textBottom += "\t\tif (null != timerDetectInputStop) {\n";
		textBottom += "\t\t\tclearTimeout(timerDetectInputStop);\n";
		textBottom += "\t\t\ttimerDetectInputStop = null;\n";
		textBottom += "\t\t}\n";
		//textBottom += "\t\tif (null != timerRefreshCanvas) {\n";
		//textBottom += "\t\t\tclearInterval(timerRefreshCanvas);\n";
		//textBottom += "\t\t\ttimerRefreshCanvas = null;\n";
		//textBottom += "\t\t}\n"
		textBottom += "\t\tshowSignature(which);\n";
		textBottom += "\t\tsaveCanvas(which);\n";
		textBottom += "\t}\n\n"
		
		textBottom += "\tfunction onkeyuphdlr(which){\n";
		//textBottom += "\t\tif (null == timerRefreshCanvas) {\n";
		//textBottom += "\t\t\ttimerRefreshCanvas = setInterval(function(){showSignature(which);}, 50);\n";
		//textBottom += "\t\t}\n"
		textBottom += "\t\tif (null != timerDetectInputStop) {\n";
		textBottom += "\t\t\tclearTimeout(timerDetectInputStop);\n";
		textBottom += "\t\t}\n";
		textBottom += "\t\ttimerDetectInputStop = setTimeout(function(){stopInput(which);}, 100);\n";
		textBottom += "\t}\n\n";
		
		/*
		function showScriptelSignature(which) {
			var divId = getElementIdPrefix(which);
			document.getElementById(divId + "-img").style.display = "inline";
			document.getElementById(divId + "-showSig").style.display = "none";
			document.getElementById(divId + "-signature").style.display = "none";
			document.getElementById(divId + "-ClearSignature").style.display = "none";
		}
		*/
		textBottom += "\tfunction showScriptelSignature(which) {\n";
		textBottom += "\t\tvar divId = getElementIdPrefix(which);\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-img&quot;).style.display = &quot;inline&quot;;\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-showSig&quot;).style.display = &quot;none&quot;;\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-signature&quot;).style.display = &quot;none&quot;;\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-ClearSignature&quot;).style.display = &quot;none&quot;;\n";
		textBottom += "\t}\n\n";
		
		/*
		function showScriptelInputBox(which) {
			var divId = getElementIdPrefix(which);
			document.getElementById(divId + "-img").style.display = "none";
			document.getElementById(divId + "-showSig").style.display = "inline";
			document.getElementById(divId + "-signature").style.display = "inline";
			document.getElementById(divId + "-ClearSignature").style.display = "inline";
		}
		*/
		textBottom += "\tfunction showScriptelInputBox(which) {\n";
		textBottom += "\t\tvar divId = getElementIdPrefix(which);\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-img&quot;).style.display = &quot;none&quot;;\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-showSig&quot;).style.display = &quot;inline&quot;;\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-signature&quot;).style.display = &quot;inline&quot;;\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-ClearSignature&quot;).style.display = &quot;inline&quot;;\n";
		textBottom += "\t}\n\n";
		
		/*
		function clearScriptelSignature(which) {
			var divId = getElementIdPrefix(which);
			var index = getSignatureIndex(which);
			document.getElementById(divId + "-img").src = "";
			document.getElementById(divId + "-img").setAttribute("savedId", "0");
			document.getElementById(divId + "-showSig").style.display = "none";
			jg[index - 1].clear();
		    //document.getElementById(divId + "-TempData").value = "";
		    //document.getElementById(divId + "-DrawData").value = "";
			document.getElementById(divId + "-signature").value = "";
		}
		*/
		textBottom += "\tfunction clearScriptelSignature(which) {\n";
		textBottom += "\t\tvar divId = getElementIdPrefix(which);\n";
		textBottom += "\t\tvar index = getSignatureIndex(which);\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-img&quot;).src = &quot;&quot;;\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-imgSavedId&quot;).value = &quot;0&quot;;\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-showSig&quot;).style.display = &quot;none&quot;;\n";
		textBottom += "\t\tjg[index - 1].clear();\n";
		//textBottom += "\t\tdocument.getElementById(divId + &quot;-TempData&quot;).value = &quot;&quot;;\n";
		//textBottom += "\t\tdocument.getElementById(divId + &quot;-DrawData&quot;).value = &quot;&quot;;\n";
		textBottom += "\t\tdocument.getElementById(divId + &quot;-signature&quot;).value = &quot;&quot;;\n";
		textBottom += "\t}\n\n";
		
		/*
		function loadSignaturePics() {
			var jsPath = "${oscar_javascript_path}";
			var reg = /\/(\S+)?\/share\/javascript/;
			var result = reg.exec(jsPath);
			if (result.length == 2) {
				contextPath=result[1];
				var imgPath = "/" + result[1] + "/imageRenderingServlet?source=signature_stored&r=107&digitalSignatureId=";
				jQuery("div[type='ScriptelSignatureBox']").each(function(){
					var savedId = document.getElementById(this.id + "-imgSavedId").value;
					if (savedId != 0 && savedId != "0") {
						document.getElementById(this.id + "-img").src = imgPath + savedId;
						showScriptelSignature(this);
					}
				});
			} else {
				alert("Error: Can't get context path!!");
			}
		}
		*/
		textBottom += "\tfunction loadSignaturePics() {\n";
		textBottom += "\t\tvar jsPath = &quot;$%7Boscar_javascript_path%7D&quot;;\n";
		textBottom += "\t\tvar reg = /\\/(\\S+)?\\/share\\/javascript/;\n";
		textBottom += "\t\tvar result = reg.exec(jsPath);\n";
		textBottom += "\t\tif (result.length == 2) {\n";
		textBottom += "\t\t\tcontextPath = &quot;/&quot; + result[1];\n";
		textBottom += "\t\t\tvar imgPath = &quot;/&quot; + result[1] + &quot;/imageRenderingServlet?source=signature_stored&r=107&digitalSignatureId=&quot;;\n";
		textBottom += "\t\t\tjQuery(&quot;div[type=\\&quot;" + scriptelSigBox + "\\&quot;]&quot;).each(function(){\n";
		textBottom += "\t\t\t\tvar savedId = document.getElementById(this.id + &quot;-imgSavedId&quot;).value;\n";
		textBottom += "\t\t\t\tif (savedId != 0 && savedId != &quot;0&quot;) {\n";
		textBottom += "\t\t\t\t\tdocument.getElementById(this.id + &quot;-img&quot;).src = imgPath + savedId;\n";
		textBottom += "\t\t\t\t\tshowScriptelSignature(this);\n";
		textBottom += "\t\t\t\t}\n";
		textBottom += "\t\t\t});\n";
		textBottom += "\t\t} else {\n";
		textBottom += "\t\t\talert(&quot;Error: Can't get context path!!&quot;);\n";
		textBottom += "\t\t}\n";
		textBottom += "\t}\n\n";
		
		/*
		function SubmitImage() {
			jQuery("div[type='ScriptelSignatureBox']").each(function(){
				document.getElementById(this.id + "-showSig").value = "";
			}
		}
		*/
		textBottom += "\tfunction SubmitImage() {\n";
		textBottom += "\t\tjQuery(&quot;div[type=\\&quot;" + scriptelSigBox + "\\&quot;]&quot;).each(function(){\n";
		textBottom += "\t\t\tdocument.getElementById(this.id + &quot;-signature&quot;).value = &quot;&quot;;\n";
		textBottom += "\t\t});\n";
		textBottom += "\t}\n\n";
		
		textBottom += "&lt;/script&gt;\n\n";
	}

	//script for Freehand drawing
	if (document.getElementById('FreehandSign').checked){
		textBottom += "&lt;!-- freehand signature scripts --&gt;\n";
		//textBottom += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_javascript_path%7Dsignature.js&quot;&gt;&lt;/script&gt;\n";
		textBottom += "&lt;script type=&quot;text/javascript&quot; src=&quot;$%7Boscar_javascript_path%7DSignatureScripts_multiple.js&quot;&gt;&lt;/script&gt;\n";
		textBottom += "&lt;script type=&quot;text/javascript&quot;&gt;\n";
		/*
		var pvcnv = document.getElementById("preview");
		var pv = new jsGraphics(pvcnv);
		var cnv = document.getElementById("SignCanvas");
		var jg = new jsGraphics(cnv);
		var cnvLeft = parseInt(cnv.style.left);
		var cnvTop = parseInt(cnv.style.top);
		var StrokeColor = "black";
		var StrokeThickness = 2;
		var x0 = 0;
		var y0 = 0;
		jg.setPrintable(true);
		var SubmitData = new Array();
		var DrawData  = new Array();
		var TempData = new Array();
		var MouseDown = false;
		var Xposition = new Array();
		var Yposition = new Array();
		var DrawSwitch = new Array();
		*/
		textBottom += "\tvar size = getSignatureCount(&quot;" + freehandSigBox + "&quot;);\n";
		textBottom += "\tvar pvcnv = new Array(size);\n";
		textBottom += "\tvar pv = new Array(size);\n";
		textBottom += "\tvar cnv = new Array(size);\n";
		textBottom += "\tvar jg = new Array(size);\n";
		textBottom += "\tvar cnvLeft = new Array(size);\n";
		textBottom += "\tvar cnvTop = new Array(size);\n";
		textBottom += "\tvar x0 = new Array(size);\n";
		textBottom += "\tvar y0 = new Array(size);\n";
		textBottom += "\tvar SubmitData = new Array();\n";
		textBottom += "\tvar DrawData  = new Array();\n";
		textBottom += "\tvar TempData = new Array();\n";
		textBottom += "\tvar MouseDown = new Array();\n";
		textBottom += "\tvar Xposition = new Array();\n";
		textBottom += "\tvar Yposition = new Array();\n";
		textBottom += "\tvar DrawSwitch = new Array();\n";
		//textBottom += "\tvar contextPath = &quot;&quot;;\n";
		
		textBottom += "\t$(function() {\n";
		
		//textBottom += "\t\tjQuery(&quot;div[type=\\&quot;" + freehandSigBox + "\\&quot;]&quot;).scriptelSigCap();\n";
		//textBottom += "\t\tjQuery(&quot;div[type=\\&quot;" + freehandSigBox + "\\&quot;]&quot;).each(function() {\n";
		//textBottom += "\t\t\tjQuery(this).click(function(){\n";
		//textBottom += "\t\t\t\twindow.console.log(this.id)\n";
		//textBottom += "\t\t\t\tvar divId = getElementIdPrefix(this);\n";
		//textBottom += "\t\t\t\t$(&quot;#&quot;+ divId).scriptelSigCap(&quot;clear&quot;);\n";
		//textBottom += "\t\t\t\t$(&quot;#&quot;+ divId).val(&quot;&quot;);\n";
		//textBottom += "\t\t\t\treturn false;\n";
		//textBottom += "\t\t\t});\n";
		//textBottom += "\t\t});\n";
		
		/*
		jQuery("div[type='FreehandSignaturebox']").each(function(){
			var index = this.getAttribute("index");
			if (index != undefined && index != null) {
				if (this != null) {
					cnv[index - 1] = this;
					jg[index - 1] = new jsGraphics(cnv[index - 1]);
					cnvLeft[index - 1] = parseInt(cnv[index - 1].style.left);
					cnvTop[index - 1] = parseInt(cnv[index - 1].style.top);
					jg[index - 1].setPrintable(true);
					
					pvcnv[index - 1] = document.getElementById(this.id + "-preview");
					pv[index - 1] = new jsGraphics(pvcnv[index - 1]);
					x0[index - 1] = 0;
					y0[index - 1] = 0;
					SubmitData[index - 1] = new Array();
					DrawData[index - 1] = new Array();
					TempData[index - 1] = new Array();
					MouseDown[index - 1] = false;
					Xposition[index - 1] = new Array();
					Yposition[index - 1] = new Array();
					DrawSwitch[index - 1] = false;
				}
			}
		});		
		*/
		textBottom += "\t\tjQuery(&quot;div[type=\\&quot;" + freehandSigBox + "\\&quot;]&quot;).each(function(){\n";
		textBottom += "\t\t\tvar index = this.getAttribute(&quot;index&quot;);\n";
		textBottom += "\t\t\tif (index != undefined && index != null) {\n";
		textBottom += "\t\t\t\tcnv[index - 1] = this;\n";
		textBottom += "\t\t\t\tif (this != null) {\n";
		textBottom += "\t\t\t\t\tjg[index - 1] = new jsGraphics(cnv[index - 1]);\n";
		textBottom += "\t\t\t\t\tcnvLeft[index - 1] = parseInt(cnv[index - 1].style.left);\n";
		textBottom += "\t\t\t\t\tcnvTop[index - 1] = parseInt(cnv[index - 1].style.top);\n";
		textBottom += "\t\t\t\t\tjg[index - 1].setPrintable(true);\n";
		textBottom += "\t\t\t\t\tpvcnv[index - 1] = document.getElementById(this.id + &quot;-preview&quot;);\n";
		textBottom += "\t\t\t\t\tpv[index - 1] = new jsGraphics(pvcnv[index - 1]);\n";
		textBottom += "\t\t\t\t\tx0[index - 1] = 0;\n";
		textBottom += "\t\t\t\t\ty0[index - 1] = 0;\n";
		textBottom += "\t\t\t\t\tSubmitData[index - 1] = new Array();\n";
		textBottom += "\t\t\t\t\tDrawData[index - 1] = new Array();\n";
		textBottom += "\t\t\t\t\tTempData[index - 1] = new Array();\n";
		textBottom += "\t\t\t\t\tMouseDown[index - 1] = false;\n";
		textBottom += "\t\t\t\t\tXposition[index - 1] = new Array();\n";
		textBottom += "\t\t\t\t\tYposition[index - 1] = new Array();\n";
		textBottom += "\t\t\t\t\tDrawSwitch[index - 1] = false;\n";
		textBottom += "\t\t\t\t}\n";
		textBottom += "\t\t\t}\n";
		textBottom += "\t\t});\n";
		
		textBottom += "\t});\n\n";
		
		textBottom += "&lt;/script&gt;\n\n";
	}
	
	if (document.getElementById('ScriptelSign').checked || document.getElementById('FreehandSign').checked) {
		
		textBottom += "&lt;script type=&quot;text/javascript&quot;&gt;\n";
		
		/*
		function getElementIdPrefix(which) {
			if (undefined == which || null == which) {
				return "";
			}
			var prefixId = which.id.substr(0, which.id.indexOf("-"));
			if (0 == prefixId.length) {
				prefixId = which.id;
			}
			return prefixId;
		}
		*/
		textBottom += "\tfunction getElementIdPrefix(which) {\n";
		textBottom += "\t\tif (undefined == which || null == which) {\n";
		textBottom += "\t\t\treturn &quot;&quot;;\n";
		textBottom += "\t\t}\n";
		textBottom += "\t\tvar prefixId = which.id.substr(0, which.id.indexOf(&quot;-&quot;));\n";
		textBottom += "\t\tif (0 == prefixId.length) {\n";
		textBottom += "\t\t\tprefixId = which.id;\n";
		textBottom += "\t\t}\n";
		textBottom += "\t\treturn prefixId;\n";
		textBottom += "\t}\n\n";
	
		/*
		function getSignatureIndex(which) {
			var divId = getElementIdPrefix(which);
			return document.getElementById(divId).getAttribute("index");
		}
		*/
		textBottom += "\tfunction getSignatureIndex(which) {\n";
		textBottom += "\t\tvar divId = getElementIdPrefix(which);\n";
		textBottom += "\t\treturn document.getElementById(divId).getAttribute(&quot;index&quot;);\n";
		textBottom += "\t}\n\n";
		
		textBottom += "&lt;/script&gt;\n\n";
	}
	
	<% } %> 
	//</body></html>
	textBottom += "&lt;/body&gt;\n&lt;/html&gt;\n";
}

//load generated eform code in new window
function popUp(){

textTop = "";
GetTextTop();

textMiddle = "";
var m = ""
for (j=0; (j < (DrawData.length) ); j++){
		var GetTextMiddleParameter = DrawData[j].split("|");
		GetTextMiddle(GetTextMiddleParameter);
	}

<% if (OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>
if (document.getElementById('AddSignature').checked){
	textMiddle +="&lt;div id=&quot;signatureDisplay&quot;&gt;&lt;/div&gt;";
	textMiddle +="&lt;input type=&quot;hidden&quot; name=&quot;signatureValue&quot; id=&quot;signatureValue&quot; value=&quot;&quot; &gt;&lt;/input&gt;";
}
<% } %>
textBottom = "";
GetTextBottom();

text = textTop  + textMiddle + textBottom;

//popup modified at this point PHC
return unescape(text);
}

//this function used for injecting html in to Edit E-Form in efmformmanageredit.jsp w/ variable formHtml
function injectHtml(){
    document.getElementById('formHtml').value = popUp();
    document.getElementById('toSave').submit();
}
//this function used for injecting html in to Edit E-Form in efmformmanageredit.jsp w/ variable formHtml BUT not efficient
function injectHtml2(){
window.open('efmformmanageredit.jsp?formHtml=','happyWindow');
happyWindow.document.getElementById('formHtml').value = popUp();
}

</script>
<!-- back to boilerplate -->

<!-- mousefunction.js -->
<script type="text/javascript">
var mousex = 0;
var mousey = 0;
var grabx = 0;
var graby = 0;
var orix = 0;
var oriy = 0;
var elex = 0;
var eley = 0;
var algor = 0;

var dragobj = null;

function falsefunc() { return false; } // used to block cascading events

function init()
{
  document.onmousemove = update; // update(event) implied on NS, update(null) implied on IE
  update();
}

function getMouseXY(e) // works on IE6,FF,Moz,Opera7
{
  if (!e) e = window.event; // works on IE, but not NS (we rely on NS passing us the event)

  if (e)
  {
    if (e.pageX || e.pageY)
    { // this doesn't work on IE6!! (works on FF,Moz,Opera7)
      mousex = e.pageX;
      mousey = e.pageY;
      algor = '[e.pageX]';
      if (e.clientX || e.clientY) algor += ' [e.clientX] '
    }
    else if (e.clientX || e.clientY)
    { // works on IE6,FF,Moz,Opera7
      // Note: I am adding together both the "body" and "documentElement" scroll positions
      //       this lets me cover for the quirks that happen based on the "doctype" of the html page.
      //         (example: IE6 in compatibility mode or strict)
      //       Based on the different ways that IE,FF,Moz,Opera use these ScrollValues for body and documentElement
      //       it looks like they will fill EITHER ONE SCROLL VALUE OR THE OTHER, NOT BOTH
      //         (from info at http://www.quirksmode.org/js/doctypes.html)
      mousex = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
      mousey = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
      algor = '[e.clientX]';
      if (e.pageX || e.pageY) algor += ' [e.pageX] '
    }
    if (e.preventDefault) {e.preventDefault();} else {window.event.returnValue = false;window.event.cancelBubble = true}
  }
}

function grab(context)
{
  document.onmousedown = falsefunc; // in NS this prevents cascading of events, thus disabling text selection
  dragobj = context;
  dragobj.style.zIndex = 10; // move it to the top
  document.onmousemove = drag;
  document.onmouseup = drop;
  grabx = mousex;
  graby = mousey;
  elex = orix = dragobj.offsetLeft;
  eley = oriy = dragobj.offsetTop;
  update();
}

function drag(e) // parameter passing is important for NS family
{
  if (dragobj)
  {
    elex = orix + (mousex-grabx);
    eley = oriy + (mousey-graby);
    dragobj.style.position = "absolute";
    dragobj.style.left = (elex).toString(10) + 'px';
    dragobj.style.top  = (eley).toString(10) + 'px';
  }
  update(e);
  return false; // in IE this prevents cascading of events, thus text selection is disabled
}

function drop()
{
	if (dragobj)
	{
		dragobj.style.zIndex = 0;
		dragobj = null;
	}
	update();
	document.onmousemove = update;
	document.onmouseup = null;
	document.onmousedown = null;   // re-enables text selection on NS

}

function update(e)
{
	  getMouseXY(e); // NS is passing (event), while IE is passing (null)
}

</script>

<!-- js graphics scripts -->
<script type="text/javascript">
/* This notice must be untouched at all times.

wz_jsgraphics.js    v. 3.01
The latest version is available at
http://www.walterzorn.com
or http://www.devira.com
or http://www.walterzorn.de

Copyright (c) 2002-2004 Walter Zorn. All rights reserved.
Created 3. 11. 2002 by Walter Zorn (Web: http://www.walterzorn.com )
Last modified: 1. 6. 2007

Performance optimizations for Internet Explorer
by Thomas Frank and John Holdsworth.
fillPolygon method implemented by Matthieu Haller.

High Performance JavaScript Graphics Library.
Provides methods
- to draw lines, rectangles, ellipses, polygons
	with specifiable line thickness,
- to fill rectangles, polygons, ellipses and arcs
- to draw text.
NOTE: Operations, functions and branching have rather been optimized
to efficiency and speed than to shortness of source code.

LICENSE: LGPL

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License (LGPL) as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA,
or see http://www.gnu.org/copyleft/lesser.html
*/


var jg_ok, jg_ie, jg_fast, jg_dom, jg_moz;


function _chkDHTM(x, i)
{
	x = document.body || null;
	jg_ie = x && typeof x.insertAdjacentHTML != "undefined" && document.createElement;
	jg_dom = (x && !jg_ie &&
		typeof x.appendChild != "undefined" &&
		typeof document.createRange != "undefined" &&
		typeof (i = document.createRange()).setStartBefore != "undefined" &&
		typeof i.createContextualFragment != "undefined");
	jg_fast = jg_ie && document.all && !window.opera;
	jg_moz = jg_dom && typeof x.style.MozOpacity != "undefined";
	jg_ok = !!(jg_ie || jg_dom);
}

function _pntCnvDom()
{
	var x = this.wnd.document.createRange();
	x.setStartBefore(this.cnv);
	x = x.createContextualFragment(jg_fast? this._htmRpc() : this.htm);
	if(this.cnv) this.cnv.appendChild(x);
	this.htm = "";
}

function _pntCnvIe()
{
	if(this.cnv) this.cnv.insertAdjacentHTML("BeforeEnd", jg_fast? this._htmRpc() : this.htm);
	this.htm = "";
}

function _pntDoc()
{
	this.wnd.document.write(jg_fast? this._htmRpc() : this.htm);
	this.htm = '';
}

function _pntN()
{
	;
}

function _mkDiv(x, y, w, h)
{
	this.htm += '<div style="position:absolute;'+
		'left:' + x + 'px;'+
		'top:' + y + 'px;'+
		'width:' + w + 'px;'+
		'height:' + h + 'px;'+
		'clip:rect(0,'+w+'px,'+h+'px,0);'+
		'background-color:' + this.color +
		(!jg_moz? ';overflow:hidden' : '')+
		';"><\/div>';
}

function _mkDivIe(x, y, w, h)
{
	this.htm += '%%'+this.color+';'+x+';'+y+';'+w+';'+h+';';
}

function _mkDivPrt(x, y, w, h)
{
	this.htm += '<div style="position:absolute;'+
		'border-left:' + w + 'px solid ' + this.color + ';'+
		'left:' + x + 'px;'+
		'top:' + y + 'px;'+
		'width:0px;'+
		'height:' + h + 'px;'+
		'clip:rect(0,'+w+'px,'+h+'px,0);'+
		'background-color:' + this.color +
		(!jg_moz? ';overflow:hidden' : '')+
		';"><\/div>';
}

var _regex =  /%%([^;]+);([^;]+);([^;]+);([^;]+);([^;]+);/g;
function _htmRpc()
{
	return this.htm.replace(
		_regex,
		'<div style="overflow:hidden;position:absolute;background-color:'+
		'$1;left:$2;top:$3;width:$4;height:$5"></div>');
}

function _htmPrtRpc()
{
	return this.htm.replace(
		_regex,
		'<div style="overflow:hidden;position:absolute;background-color:'+
		'$1;left:$2;top:$3;width:$4;height:$5;border-left:$4px solid $1"></div>');
}

function _mkLin(x1, y1, x2, y2)
{
	if(x1 > x2)
	{
		var _x2 = x2;
		var _y2 = y2;
		x2 = x1;
		y2 = y1;
		x1 = _x2;
		y1 = _y2;
	}
	var dx = x2-x1, dy = Math.abs(y2-y1),
	x = x1, y = y1,
	yIncr = (y1 > y2)? -1 : 1;

	if(dx >= dy)
	{
		var pr = dy<<1,
		pru = pr - (dx<<1),
		p = pr-dx,
		ox = x;
		while(dx > 0)
		{--dx;
			++x;
			if(p > 0)
			{
				this._mkDiv(ox, y, x-ox, 1);
				y += yIncr;
				p += pru;
				ox = x;
			}
			else p += pr;
		}
		this._mkDiv(ox, y, x2-ox+1, 1);
	}

	else
	{
		var pr = dx<<1,
		pru = pr - (dy<<1),
		p = pr-dy,
		oy = y;
		if(y2 <= y1)
		{
			while(dy > 0)
			{--dy;
				if(p > 0)
				{
					this._mkDiv(x++, y, 1, oy-y+1);
					y += yIncr;
					p += pru;
					oy = y;
				}
				else
				{
					y += yIncr;
					p += pr;
				}
			}
			this._mkDiv(x2, y2, 1, oy-y2+1);
		}
		else
		{
			while(dy > 0)
			{--dy;
				y += yIncr;
				if(p > 0)
				{
					this._mkDiv(x++, oy, 1, y-oy);
					p += pru;
					oy = y;
				}
				else p += pr;
			}
			this._mkDiv(x2, oy, 1, y2-oy+1);
		}
	}
}

function _mkLin2D(x1, y1, x2, y2)
{
	if(x1 > x2)
	{
		var _x2 = x2;
		var _y2 = y2;
		x2 = x1;
		y2 = y1;
		x1 = _x2;
		y1 = _y2;
	}
	var dx = x2-x1, dy = Math.abs(y2-y1),
	x = x1, y = y1,
	yIncr = (y1 > y2)? -1 : 1;

	var s = this.stroke;
	if(dx >= dy)
	{
		if(dx > 0 && s-3 > 0)
		{
			var _s = (s*dx*Math.sqrt(1+dy*dy/(dx*dx))-dx-(s>>1)*dy) / dx;
			_s = (!(s-4)? Math.ceil(_s) : Math.round(_s)) + 1;
		}
		else var _s = s;
		var ad = Math.ceil(s/2);

		var pr = dy<<1,
		pru = pr - (dx<<1),
		p = pr-dx,
		ox = x;
		while(dx > 0)
		{--dx;
			++x;
			if(p > 0)
			{
				this._mkDiv(ox, y, x-ox+ad, _s);
				y += yIncr;
				p += pru;
				ox = x;
			}
			else p += pr;
		}
		this._mkDiv(ox, y, x2-ox+ad+1, _s);
	}

	else
	{
		if(s-3 > 0)
		{
			var _s = (s*dy*Math.sqrt(1+dx*dx/(dy*dy))-(s>>1)*dx-dy) / dy;
			_s = (!(s-4)? Math.ceil(_s) : Math.round(_s)) + 1;
		}
		else var _s = s;
		var ad = Math.round(s/2);

		var pr = dx<<1,
		pru = pr - (dy<<1),
		p = pr-dy,
		oy = y;
		if(y2 <= y1)
		{
			++ad;
			while(dy > 0)
			{--dy;
				if(p > 0)
				{
					this._mkDiv(x++, y, _s, oy-y+ad);
					y += yIncr;
					p += pru;
					oy = y;
				}
				else
				{
					y += yIncr;
					p += pr;
				}
			}
			this._mkDiv(x2, y2, _s, oy-y2+ad);
		}
		else
		{
			while(dy > 0)
			{--dy;
				y += yIncr;
				if(p > 0)
				{
					this._mkDiv(x++, oy, _s, y-oy+ad);
					p += pru;
					oy = y;
				}
				else p += pr;
			}
			this._mkDiv(x2, oy, _s, y2-oy+ad+1);
		}
	}
}

function _mkLinDott(x1, y1, x2, y2)
{
	if(x1 > x2)
	{
		var _x2 = x2;
		var _y2 = y2;
		x2 = x1;
		y2 = y1;
		x1 = _x2;
		y1 = _y2;
	}
	var dx = x2-x1, dy = Math.abs(y2-y1),
	x = x1, y = y1,
	yIncr = (y1 > y2)? -1 : 1,
	drw = true;
	if(dx >= dy)
	{
		var pr = dy<<1,
		pru = pr - (dx<<1),
		p = pr-dx;
		while(dx > 0)
		{--dx;
			if(drw) this._mkDiv(x, y, 1, 1);
			drw = !drw;
			if(p > 0)
			{
				y += yIncr;
				p += pru;
			}
			else p += pr;
			++x;
		}
	}
	else
	{
		var pr = dx<<1,
		pru = pr - (dy<<1),
		p = pr-dy;
		while(dy > 0)
		{--dy;
			if(drw) this._mkDiv(x, y, 1, 1);
			drw = !drw;
			y += yIncr;
			if(p > 0)
			{
				++x;
				p += pru;
			}
			else p += pr;
		}
	}
	if(drw) this._mkDiv(x, y, 1, 1);
}

function _mkOv(left, top, width, height)
{
	var a = (++width)>>1, b = (++height)>>1,
	wod = width&1, hod = height&1,
	cx = left+a, cy = top+b,
	x = 0, y = b,
	ox = 0, oy = b,
	aa2 = (a*a)<<1, aa4 = aa2<<1, bb2 = (b*b)<<1, bb4 = bb2<<1,
	st = (aa2>>1)*(1-(b<<1)) + bb2,
	tt = (bb2>>1) - aa2*((b<<1)-1),
	w, h;
	while(y > 0)
	{
		if(st < 0)
		{
			st += bb2*((x<<1)+3);
			tt += bb4*(++x);
		}
		else if(tt < 0)
		{
			st += bb2*((x<<1)+3) - aa4*(y-1);
			tt += bb4*(++x) - aa2*(((y--)<<1)-3);
			w = x-ox;
			h = oy-y;
			if((w&2) && (h&2))
			{
				this._mkOvQds(cx, cy, x-2, y+2, 1, 1, wod, hod);
				this._mkOvQds(cx, cy, x-1, y+1, 1, 1, wod, hod);
			}
			else this._mkOvQds(cx, cy, x-1, oy, w, h, wod, hod);
			ox = x;
			oy = y;
		}
		else
		{
			tt -= aa2*((y<<1)-3);
			st -= aa4*(--y);
		}
	}
	w = a-ox+1;
	h = (oy<<1)+hod;
	y = cy-oy;
	this._mkDiv(cx-a, y, w, h);
	this._mkDiv(cx+ox+wod-1, y, w, h);
}

function _mkOv2D(left, top, width, height)
{
	var s = this.stroke;
	width += s+1;
	height += s+1;
	var a = width>>1, b = height>>1,
	wod = width&1, hod = height&1,
	cx = left+a, cy = top+b,
	x = 0, y = b,
	aa2 = (a*a)<<1, aa4 = aa2<<1, bb2 = (b*b)<<1, bb4 = bb2<<1,
	st = (aa2>>1)*(1-(b<<1)) + bb2,
	tt = (bb2>>1) - aa2*((b<<1)-1);

	if(s-4 < 0 && (!(s-2) || width-51 > 0 && height-51 > 0))
	{
		var ox = 0, oy = b,
		w, h,
		pxw;
		while(y > 0)
		{
			if(st < 0)
			{
				st += bb2*((x<<1)+3);
				tt += bb4*(++x);
			}
			else if(tt < 0)
			{
				st += bb2*((x<<1)+3) - aa4*(y-1);
				tt += bb4*(++x) - aa2*(((y--)<<1)-3);
				w = x-ox;
				h = oy-y;

				if(w-1)
				{
					pxw = w+1+(s&1);
					h = s;
				}
				else if(h-1)
				{
					pxw = s;
					h += 1+(s&1);
				}
				else pxw = h = s;
				this._mkOvQds(cx, cy, x-1, oy, pxw, h, wod, hod);
				ox = x;
				oy = y;
			}
			else
			{
				tt -= aa2*((y<<1)-3);
				st -= aa4*(--y);
			}
		}
		this._mkDiv(cx-a, cy-oy, s, (oy<<1)+hod);
		this._mkDiv(cx+a+wod-s, cy-oy, s, (oy<<1)+hod);
	}

	else
	{
		var _a = (width-(s<<1))>>1,
		_b = (height-(s<<1))>>1,
		_x = 0, _y = _b,
		_aa2 = (_a*_a)<<1, _aa4 = _aa2<<1, _bb2 = (_b*_b)<<1, _bb4 = _bb2<<1,
		_st = (_aa2>>1)*(1-(_b<<1)) + _bb2,
		_tt = (_bb2>>1) - _aa2*((_b<<1)-1),

		pxl = new Array(),
		pxt = new Array(),
		_pxb = new Array();
		pxl[0] = 0;
		pxt[0] = b;
		_pxb[0] = _b-1;
		while(y > 0)
		{
			if(st < 0)
			{
				pxl[pxl.length] = x;
				pxt[pxt.length] = y;
				st += bb2*((x<<1)+3);
				tt += bb4*(++x);
			}
			else if(tt < 0)
			{
				pxl[pxl.length] = x;
				st += bb2*((x<<1)+3) - aa4*(y-1);
				tt += bb4*(++x) - aa2*(((y--)<<1)-3);
				pxt[pxt.length] = y;
			}
			else
			{
				tt -= aa2*((y<<1)-3);
				st -= aa4*(--y);
			}

			if(_y > 0)
			{
				if(_st < 0)
				{
					_st += _bb2*((_x<<1)+3);
					_tt += _bb4*(++_x);
					_pxb[_pxb.length] = _y-1;
				}
				else if(_tt < 0)
				{
					_st += _bb2*((_x<<1)+3) - _aa4*(_y-1);
					_tt += _bb4*(++_x) - _aa2*(((_y--)<<1)-3);
					_pxb[_pxb.length] = _y-1;
				}
				else
				{
					_tt -= _aa2*((_y<<1)-3);
					_st -= _aa4*(--_y);
					_pxb[_pxb.length-1]--;
				}
			}
		}

		var ox = -wod, oy = b,
		_oy = _pxb[0],
		l = pxl.length,
		w, h;
		for(var i = 0; i < l; i++)
		{
			if(typeof _pxb[i] != "undefined")
			{
				if(_pxb[i] < _oy || pxt[i] < oy)
				{
					x = pxl[i];
					this._mkOvQds(cx, cy, x, oy, x-ox, oy-_oy, wod, hod);
					ox = x;
					oy = pxt[i];
					_oy = _pxb[i];
				}
			}
			else
			{
				x = pxl[i];
				this._mkDiv(cx-x, cy-oy, 1, (oy<<1)+hod);
				this._mkDiv(cx+ox+wod, cy-oy, 1, (oy<<1)+hod);
				ox = x;
				oy = pxt[i];
			}
		}
		this._mkDiv(cx-a, cy-oy, 1, (oy<<1)+hod);
		this._mkDiv(cx+ox+wod, cy-oy, 1, (oy<<1)+hod);
	}
}

function _mkOvDott(left, top, width, height)
{
	var a = (++width)>>1, b = (++height)>>1,
	wod = width&1, hod = height&1, hodu = hod^1,
	cx = left+a, cy = top+b,
	x = 0, y = b,
	aa2 = (a*a)<<1, aa4 = aa2<<1, bb2 = (b*b)<<1, bb4 = bb2<<1,
	st = (aa2>>1)*(1-(b<<1)) + bb2,
	tt = (bb2>>1) - aa2*((b<<1)-1),
	drw = true;
	while(y > 0)
	{
		if(st < 0)
		{
			st += bb2*((x<<1)+3);
			tt += bb4*(++x);
		}
		else if(tt < 0)
		{
			st += bb2*((x<<1)+3) - aa4*(y-1);
			tt += bb4*(++x) - aa2*(((y--)<<1)-3);
		}
		else
		{
			tt -= aa2*((y<<1)-3);
			st -= aa4*(--y);
		}
		if(drw && y >= hodu) this._mkOvQds(cx, cy, x, y, 1, 1, wod, hod);
		drw = !drw;
	}
}

function _mkRect(x, y, w, h)
{
	var s = this.stroke;
	this._mkDiv(x, y, w, s);
	this._mkDiv(x+w, y, s, h);
	this._mkDiv(x, y+h, w+s, s);
	this._mkDiv(x, y+s, s, h-s);
}

function _mkRectDott(x, y, w, h)
{
	this.drawLine(x, y, x+w, y);
	this.drawLine(x+w, y, x+w, y+h);
	this.drawLine(x, y+h, x+w, y+h);
	this.drawLine(x, y, x, y+h);
}

function jsgFont()
{
	this.PLAIN = 'font-weight:normal;';
	this.BOLD = 'font-weight:bold;';
	this.ITALIC = 'font-style:italic;';
	this.ITALIC_BOLD = this.ITALIC + this.BOLD;
	this.BOLD_ITALIC = this.ITALIC_BOLD;
}
var Font = new jsgFont();

function jsgStroke()
{
	this.DOTTED = -1;
}
var Stroke = new jsgStroke();

function jsGraphics(cnv, wnd)
{
	this.setColor = function(x)
	{
		this.color = x.toLowerCase();
	};

	this.setStroke = function(x)
	{
		this.stroke = x;
		if(!(x+1))
		{
			this.drawLine = _mkLinDott;
			this._mkOv = _mkOvDott;
			this.drawRect = _mkRectDott;
		}
		else if(x-1 > 0)
		{
			this.drawLine = _mkLin2D;
			this._mkOv = _mkOv2D;
			this.drawRect = _mkRect;
		}
		else
		{
			this.drawLine = _mkLin;
			this._mkOv = _mkOv;
			this.drawRect = _mkRect;
		}
	};

	this.setPrintable = function(arg)
	{
		this.printable = arg;
		if(jg_fast)
		{
			this._mkDiv = _mkDivIe;
			this._htmRpc = arg? _htmPrtRpc : _htmRpc;
		}
		else this._mkDiv = arg? _mkDivPrt : _mkDiv;
	};

	this.setFont = function(fam, sz, sty)
	{
		this.ftFam = fam;
		this.ftSz = sz;
		this.ftSty = sty || Font.PLAIN;
	};

	this.drawPolyline = this.drawPolyLine = function(x, y)
	{
		for (var i=x.length - 1; i;)
		{--i;
			this.drawLine(x[i], y[i], x[i+1], y[i+1]);
		}
	};

	this.fillRect = function(x, y, w, h)
	{
		this._mkDiv(x, y, w, h);
	};

	this.drawPolygon = function(x, y)
	{
		this.drawPolyline(x, y);
		this.drawLine(x[x.length-1], y[x.length-1], x[0], y[0]);
	};

	this.drawEllipse = this.drawOval = function(x, y, w, h)
	{
		this._mkOv(x, y, w, h);
	};

	this.fillEllipse = this.fillOval = function(left, top, w, h)
	{
		var a = w>>1, b = h>>1,
		wod = w&1, hod = h&1,
		cx = left+a, cy = top+b,
		x = 0, y = b, oy = b,
		aa2 = (a*a)<<1, aa4 = aa2<<1, bb2 = (b*b)<<1, bb4 = bb2<<1,
		st = (aa2>>1)*(1-(b<<1)) + bb2,
		tt = (bb2>>1) - aa2*((b<<1)-1),
		xl, dw, dh;
		if(w) while(y > 0)
		{
			if(st < 0)
			{
				st += bb2*((x<<1)+3);
				tt += bb4*(++x);
			}
			else if(tt < 0)
			{
				st += bb2*((x<<1)+3) - aa4*(y-1);
				xl = cx-x;
				dw = (x<<1)+wod;
				tt += bb4*(++x) - aa2*(((y--)<<1)-3);
				dh = oy-y;
				this._mkDiv(xl, cy-oy, dw, dh);
				this._mkDiv(xl, cy+y+hod, dw, dh);
				oy = y;
			}
			else
			{
				tt -= aa2*((y<<1)-3);
				st -= aa4*(--y);
			}
		}
		this._mkDiv(cx-a, cy-oy, w, (oy<<1)+hod);
	};

	this.fillArc = function(iL, iT, iW, iH, fAngA, fAngZ)
	{
		var a = iW>>1, b = iH>>1,
		iOdds = (iW&1) | ((iH&1) << 16),
		cx = iL+a, cy = iT+b,
		x = 0, y = b, ox = x, oy = y,
		aa2 = (a*a)<<1, aa4 = aa2<<1, bb2 = (b*b)<<1, bb4 = bb2<<1,
		st = (aa2>>1)*(1-(b<<1)) + bb2,
		tt = (bb2>>1) - aa2*((b<<1)-1),
		// Vars for radial boundary lines
		xEndA, yEndA, xEndZ, yEndZ,
		iSects = (1 << (Math.floor((fAngA %= 360.0)/180.0) << 3))
				| (2 << (Math.floor((fAngZ %= 360.0)/180.0) << 3))
				| ((fAngA >= fAngZ) << 16),
		aBndA = new Array(b+1), aBndZ = new Array(b+1);

		// Set up radial boundary lines
		fAngA *= Math.PI/180.0;
		fAngZ *= Math.PI/180.0;
		xEndA = cx+Math.round(a*Math.cos(fAngA));
		yEndA = cy+Math.round(-b*Math.sin(fAngA));
		_mkLinVirt(aBndA, cx, cy, xEndA, yEndA);
		xEndZ = cx+Math.round(a*Math.cos(fAngZ));
		yEndZ = cy+Math.round(-b*Math.sin(fAngZ));
		_mkLinVirt(aBndZ, cx, cy, xEndZ, yEndZ);

		while(y > 0)
		{
			if(st < 0) // Advance x
			{
				st += bb2*((x<<1)+3);
				tt += bb4*(++x);
			}
			else if(tt < 0) // Advance x and y
			{
				st += bb2*((x<<1)+3) - aa4*(y-1);
				ox = x;
				tt += bb4*(++x) - aa2*(((y--)<<1)-3);
				this._mkArcDiv(ox, y, oy, cx, cy, iOdds, aBndA, aBndZ, iSects);
				oy = y;
			}
			else // Advance y
			{
				tt -= aa2*((y<<1)-3);
				st -= aa4*(--y);
				if(y && (aBndA[y] != aBndA[y-1] || aBndZ[y] != aBndZ[y-1]))
				{
					this._mkArcDiv(x, y, oy, cx, cy, iOdds, aBndA, aBndZ, iSects);
					ox = x;
					oy = y;
				}
			}
		}
		this._mkArcDiv(x, 0, oy, cx, cy, iOdds, aBndA, aBndZ, iSects);
		if(iOdds >> 16) // Odd height
		{
			if(iSects >> 16) // Start-angle > end-angle
			{
				var xl = (yEndA <= cy || yEndZ > cy)? (cx - x) : cx;
				this._mkDiv(xl, cy, x + cx - xl + (iOdds & 0xffff), 1);
			}
			else if((iSects & 0x01) && yEndZ > cy)
				this._mkDiv(cx - x, cy, x, 1);
		}
	};

/* fillPolygon method, implemented by Matthieu Haller.
This javascript function is an adaptation of the gdImageFilledPolygon for Walter Zorn lib.
C source of GD 1.8.4 found at http://www.boutell.com/gd/

THANKS to Kirsten Schulz for the polygon fixes!

The intersection finding technique of this code could be improved
by remembering the previous intertersection, and by using the slope.
That could help to adjust intersections to produce a nice
interior_extrema. */
	this.fillPolygon = function(array_x, array_y)
	{
		var i;
		var y;
		var miny, maxy;
		var x1, y1;
		var x2, y2;
		var ind1, ind2;
		var ints;

		var n = array_x.length;
		if(!n) return;

		miny = array_y[0];
		maxy = array_y[0];
		for(i = 1; i < n; i++)
		{
			if(array_y[i] < miny)
				miny = array_y[i];

			if(array_y[i] > maxy)
				maxy = array_y[i];
		}
		for(y = miny; y <= maxy; y++)
		{
			var polyInts = new Array();
			ints = 0;
			for(i = 0; i < n; i++)
			{
				if(!i)
				{
					ind1 = n-1;
					ind2 = 0;
				}
				else
				{
					ind1 = i-1;
					ind2 = i;
				}
				y1 = array_y[ind1];
				y2 = array_y[ind2];
				if(y1 < y2)
				{
					x1 = array_x[ind1];
					x2 = array_x[ind2];
				}
				else if(y1 > y2)
				{
					y2 = array_y[ind1];
					y1 = array_y[ind2];
					x2 = array_x[ind1];
					x1 = array_x[ind2];
				}
				else continue;

				 //  Modified 11. 2. 2004 Walter Zorn
				if((y >= y1) && (y < y2))
					polyInts[ints++] = Math.round((y-y1) * (x2-x1) / (y2-y1) + x1);

				else if((y == maxy) && (y > y1) && (y <= y2))
					polyInts[ints++] = Math.round((y-y1) * (x2-x1) / (y2-y1) + x1);
			}
			polyInts.sort(_CompInt);
			for(i = 0; i < ints; i+=2)
				this._mkDiv(polyInts[i], y, polyInts[i+1]-polyInts[i]+1, 1);
		}
	};

	this.drawString = function(txt, x, y)
	{
		this.htm += '<div style="position:absolute;white-space:nowrap;'+
			'left:' + x + 'px;'+
			'top:' + y + 'px;'+
			'font-family:' +  this.ftFam + ';'+
			'font-size:' + this.ftSz + ';'+
			'color:' + this.color + ';' + this.ftSty + '">'+
			txt +
			'<\/div>';
	};

/* drawStringRect() added by Rick Blommers.
Allows to specify the size of the text rectangle and to align the
text both horizontally (e.g. right) and vertically within that rectangle */
	this.drawStringRect = function(txt, x, y, width, halign)
	{
		this.htm += '<div style="position:absolute;overflow:hidden;'+
			'left:' + x + 'px;'+
			'top:' + y + 'px;'+
			'width:'+width +'px;'+
			'text-align:'+halign+';'+
			'font-family:' +  this.ftFam + ';'+
			'font-size:' + this.ftSz + ';'+
			'color:' + this.color + ';' + this.ftSty + '">'+
			txt +
			'<\/div>';
	};

	this.drawImage = function(imgSrc, x, y, w, h, a)
	{
		this.htm += '<div style="position:absolute;'+
			'left:' + x + 'px;'+
			'top:' + y + 'px;'+
			'width:' +  w + 'px;'+
			'height:' + h + 'px;">'+
			'<img src="' + imgSrc + '" width="' + w + '" height="' + h + '"' + (a? (' '+a) : '') + '>'+
			'<\/div>';
	};

	this.clear = function()
	{
		this.htm = "";
		if(this.cnv) this.cnv.innerHTML = "";
	};

	this._mkOvQds = function(cx, cy, x, y, w, h, wod, hod)
	{
		var xl = cx - x, xr = cx + x + wod - w, yt = cy - y, yb = cy + y + hod - h;
		if(xr > xl+w)
		{
			this._mkDiv(xr, yt, w, h);
			this._mkDiv(xr, yb, w, h);
		}
		else
			w = xr - xl + w;
		this._mkDiv(xl, yt, w, h);
		this._mkDiv(xl, yb, w, h);
	};

	this._mkArcDiv = function(x, y, oy, cx, cy, iOdds, aBndA, aBndZ, iSects)
	{
		var xrDef = cx + x + (iOdds & 0xffff), y2, h = oy - y, xl, xr, w;

		if(!h) h = 1;
		x = cx - x;

		if(iSects & 0xff0000) // Start-angle > end-angle
		{
			y2 = cy - y - h;
			if(iSects & 0x00ff)
			{
				if(iSects & 0x02)
				{
					xl = Math.max(x, aBndZ[y]);
					w = xrDef - xl;
					if(w > 0) this._mkDiv(xl, y2, w, h);
				}
				if(iSects & 0x01)
				{
					xr = Math.min(xrDef, aBndA[y]);
					w = xr - x;
					if(w > 0) this._mkDiv(x, y2, w, h);
				}
			}
			else
				this._mkDiv(x, y2, xrDef - x, h);
			y2 = cy + y + (iOdds >> 16);
			if(iSects & 0xff00)
			{
				if(iSects & 0x0100)
				{
					xl = Math.max(x, aBndA[y]);
					w = xrDef - xl;
					if(w > 0) this._mkDiv(xl, y2, w, h);
				}
				if(iSects & 0x0200)
				{
					xr = Math.min(xrDef, aBndZ[y]);
					w = xr - x;
					if(w > 0) this._mkDiv(x, y2, w, h);
				}
			}
			else
				this._mkDiv(x, y2, xrDef - x, h);
		}
		else
		{
			if(iSects & 0x00ff)
			{
				if(iSects & 0x02)
					xl = Math.max(x, aBndZ[y]);
				else
					xl = x;
				if(iSects & 0x01)
					xr = Math.min(xrDef, aBndA[y]);
				else
					xr = xrDef;
				y2 = cy - y - h;
				w = xr - xl;
				if(w > 0) this._mkDiv(xl, y2, w, h);
			}
			if(iSects & 0xff00)
			{
				if(iSects & 0x0100)
					xl = Math.max(x, aBndA[y]);
				else
					xl = x;
				if(iSects & 0x0200)
					xr = Math.min(xrDef, aBndZ[y]);
				else
					xr = xrDef;
				y2 = cy + y + (iOdds >> 16);
				w = xr - xl;
				if(w > 0) this._mkDiv(xl, y2, w, h);
			}
		}
	};

	this.setStroke(1);
	this.setFont("verdana,geneva,helvetica,sans-serif", "12px", Font.PLAIN);
	this.color = "#000000";
	this.htm = "";
	this.wnd = wnd || window;

	if(!jg_ok) _chkDHTM();
	if(jg_ok)
	{
		if(cnv)
		{
			if(typeof(cnv) == "string")
				this.cont = document.all? (this.wnd.document.all[cnv] || null)
					: document.getElementById? (this.wnd.document.getElementById(cnv) || null)
					: null;
			else if(cnv == window.document)
				this.cont = document.getElementsByTagName("body")[0];
			// If cnv is a direct reference to a canvas DOM node
			// (option suggested by Andreas Luleich)
			else this.cont = cnv;
			// Create new canvas inside container DIV. Thus the drawing and clearing
			// methods won't interfere with the container's inner html.
			// Solution suggested by Vladimir.
			this.cnv = document.createElement("div");
			this.cont.appendChild(this.cnv);
			this.paint = jg_dom? _pntCnvDom : _pntCnvIe;
		}
		else
			this.paint = _pntDoc;
	}
	else
		this.paint = _pntN;

	this.setPrintable(false);
}

function _mkLinVirt(aLin, x1, y1, x2, y2)
{
	var dx = Math.abs(x2-x1), dy = Math.abs(y2-y1),
	x = x1, y = y1,
	xIncr = (x1 > x2)? -1 : 1,
	yIncr = (y1 > y2)? -1 : 1,
	p,
	i = 0;
	if(dx >= dy)
	{
		var pr = dy<<1,
		pru = pr - (dx<<1);
		p = pr-dx;
		while(dx > 0)
		{--dx;
			if(p > 0)    //  Increment y
			{
				aLin[i++] = x;
				y += yIncr;
				p += pru;
			}
			else p += pr;
			x += xIncr;
		}
	}
	else
	{
		var pr = dx<<1,
		pru = pr - (dy<<1);
		p = pr-dy;
		while(dy > 0)
		{--dy;
			y += yIncr;
			aLin[i++] = x;
			if(p > 0)    //  Increment x
			{
				x += xIncr;
				p += pru;
			}
			else p += pr;
		}
	}
	for(var len = aLin.length, i = len-i; i;)
		aLin[len-(i--)] = x;
};

function _CompInt(x, y)
{
	return(x - y);
}



</script>

</head>

<!-- resetAll() -->
<body onload="init(); resetAll(); hide('all');">

<img name="BGImage" id="BGImage" style="position: absolute; left: 0px; top: 0px;"
	onmouseover="SetDrawOn();"
	onmouseout="SetDrawOff();"
	onmousedown="if (event.preventDefault) event.preventDefault(); SetMouseDown();SetStart();"
	onmousemove=""
	onmouseup="SetMouseUp(); DrawMarker();loadInputList();"
	onload="finishLoadingImage()">

<h1><bean:message key="eFormGenerator.title"/></h1>

<!-- this form  used for injecting html in to Edit E-Form-->
<form method="post" action="efmformmanageredit.jsp" id="toSave">
    <input type="hidden" name="formHtml" id="formHtml" />
</form>

<form method="post" action="" name="FormName" id="FormName">
<!-- <div name="Wizard" id="Wizard" class="DoNotPrint" style="position: absolute; left:750px; top: 0px; width: 500px; padding:5px" > -->
<div name="Wizard" id="Wizard" class="DoNotPrint" style="position: absolute; leftoscar_image_path:750px; top: 0px; width: 500px;" >


<span class="h1"><bean:message key="eFormGenerator.title"/></span>
	<a onclick="show('all');"><bean:message key="eFormGenerator.expandAll"/></a>/
	<a onclick="hide('all');"><bean:message key="eFormGenerator.collapseAll"/></a>

<hr>
<span class="h2">1. <bean:message key="eFormGenerator.loadImage"/>:</span> <a onclick="show('Section1');"><bean:message key="eFormGenerator.expand"/></a>/<a onclick="hide('Section1');"><bean:message key="eFormGenerator.collapse"/></a>
<div id="Section1">
 <p><select name="imageName" id="imageName">
                 <option value=""                    ><bean:message key="eFormGenerator.imageChooseSelect"/>...</option>
                    <%
                    /**
                        this function/scriplet look in images directory and populate the selection
                        so that the user can select which image they want to use for generating an eform
                    */
                     OscarProperties oscarProps = OscarProperties.getInstance();

                     DisplayImageAction test = new DisplayImageAction();
                     File dir=null;
                        try {
                            dir =new File(oscarProps.getProperty("eform_image"));
                        } catch(Exception e){
                        	MiscUtils.getLogger().error("Unable to locate image directory", e);
                        }
                     String output = null;
                     for(int i=0;i<(test.visitAllFiles(dir)).length;i++){
                       output=test.visitAllFiles(dir)[i]; %>
                       <option value="<%= output %>"  ><%= output %></option>

                       <%
                      }
                     %>
            </select>
        </p>

	<!-- <p><b>Image Name:</b><input type="text" name="imageName" id="imageName"></p> -->
	<p>	- <bean:message key="eFormGenerator.imageUploadPrompt"/> <bean:message key="eFormGenerator.imageUploadLink"/></p>
	<p><b>Orientation of form:</b><br>
			<input type="radio" name="Orientation" id="OrientPortrait" value="750" checked><bean:message key="eFormGenerator.imagePortrait"/><br>
			<input type="radio" name="Orientation" id="OrientLandscape" value="1000"><bean:message key="eFormGenerator.imageLandscape"/><br>
			<input type="radio" name="Orientation" id="OrientCustom" value="CustomWidth"><bean:message key="eFormGenerator.imageCustom"/> <input type="text" name="OrientCustomValue" id="OrientCustomValue" width="100"> <bean:message key="eFormGenerator.imageEnterInteger"/><br>
			<input type="button" value=<bean:message key="eFormGenerator.imageLoadButton"/> onClick="loadImage();">
	</p>
	<p><bean:message key="eFormGenerator.image.RedOutlinehint"/></p>

</div>

<hr>

<span class='h2'>2. <bean:message key="eFormGenerator.eFormName"/></span> <a onclick="show('Section2');"><bean:message key="eFormGenerator.expand"/></a>/<a onclick="hide('Section2');"><bean:message key="eFormGenerator.collapse"/></a>
<div id="Section2">
	<p><bean:message key="eFormGenerator.nameInstruction"/><input type="text" name="eFormName" id="eFormName"></p>
</div>

<hr>

<span class='h2'>3. <bean:message key="eFormGenerator.gender"/></span> <a onclick="show('Section3');"><bean:message key="eFormGenerator.expand"/></a>/<a onclick="hide('Section3');"><bean:message key="eFormGenerator.collapse"/></a>
<div id="Section3">
			<p><bean:message key="eFormGenerator.genderCheckbox"/> <input name="preCheckGender" id="preCheckGender" type="checkbox" onclick="toggleView(this.checked,'Section3a');"></p>
			<div id="Section3a" style="display:none">
				<table>
					<tr>
						<td><span><b><bean:message key="eFormGenerator.genderMale"/></b>: </span></td>
						<td><input name="Male" id="Male" type="button" value='<bean:message key="eFormGenerator.genderMaleButton"/>' onclick="SetSwitchOn(this.id);"></td>
					</tr>
					<tr>
						<td><span><b><bean:message key="eFormGenerator.genderFemale"/></b>:</span></td>
						<td><input name="Female" id="Female" type="button" value='<bean:message key="eFormGenerator.genderFemaleButton"/>' onclick="SetSwitchOn(this.id);"></td>
					</tr>
				</table>
			</div>
</div>
<hr>
<% if (OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_signature_enabled")) { %>
<span class='h2'>4. <bean:message key="eFormGenerator.signature"/></span><a onclick="show('Section4');"><bean:message key="eFormGenerator.expand"/></a>/<a onclick="hide('Section4');"><bean:message key="eFormGenerator.collapse"/></a>
<div id="Section4">
		<div id="Section4a">
			<input type="radio" name="inputType" id="IndivicaSignature" value="checkbox" onclick="document.getElementById('AddSignature').checked=true;SetSwitchOn(this.id);"><span><bean:message key="eFormGenerator.signatureCheckbox"/></span>
			<input type="checkbox" name="AddSignature" id="AddSignature" style="display:none">
		</div>		
</div>
<% } else { %>
<span class='h2'>4. <bean:message key="eFormGenerator.signature"/></span><a onclick="show('Section4');"><bean:message key="eFormGenerator.expand"/></a>/<a onclick="hide('Section4');"><bean:message key="eFormGenerator.collapse"/></a>
<div id="Section4">
	<p>
		<% if(OscarProperties.getInstance().getBooleanProperty("eform_signature_scriptel_enabled","true")){ %>
		<input type="checkbox" name="AddSignature" id="AddSignature"
			onclick="toggleView(this.checked,'Section4a');toggleView(this.checked,'Section4b');toggleView(this.checked,'Section4c');"><bean:message key="eFormGenerator.signatureCheckbox"/>
		<%} else {%>
		<input type="checkbox" name="AddSignature" id="AddSignature"
			onclick="toggleView(this.checked,'Section4a');toggleView(this.checked,'Section4b');"><bean:message key="eFormGenerator.signatureCheckbox"/>
		<%} %>
		<br>		
		<div id="Section4a" style="display:none">
			<input type="radio" name="SignatureType" id="AutoSign" value="AutoSign" onclick="show('Section4aa'); show('Section4ab'); hide('Section4ba');hide('Section4ca');"><span><bean:message key="eFormGenerator.signatureLoad"/></span><br>
		</div>
		<div id="Section4aa" style="display:none">
			<ul>
				<li><bean:message key="eFormGenerator.signatureFragment"/>
					<input type="text" name="UserList" id="UserList" style="width:200px;"></li>
				<li><bean:message key="eFormGenerator.signatureImage"/>
					<input type="text" name="SignatureList" id="SignatureList" style="width:200px;"></li>
				<input type="button" name="AddToUserSignatureList" id="AddToUserSignatureList" value="<bean:message key="eFormGenerator.signatureAddButton"/>" onclick="addToUserSignatureList();">
				<input type="button" name="EmptyUserSignatureList" id="EmptyUserSignatureList" value="<bean:message key="eFormGenerator.signatureEmptyButton"/>" onclick="emptyUserSignaturelist()"><br>
				<ul name="UserSignatureList" id="UserSignatureList" style="list-style-type:none; list-style: none; margin-left: 0; padding-left: 1em; text-indent: -1em"></ul>
			</ul>
		</div>
		<div id="Section4ab" style="display:none">
			<input type="button" name="AddScriptelSignature" id="AddScriptelSignature" style="width:400px" value="<bean:message key="eFormGenerator.signatureLocationButton"/>" onclick="SetSwitchOn('SignatureBox');">
		</div>
		
		<!-- freehand signature -->
		<div id="Section4b"  style="display:none">
			<input type="radio" name="SignatureType" id="FreehandSign" value="FreehandSign" onclick="show('Section4ba'); hide('Section4aa'); hide('Section4ab');hide('Section4ca');"><span><bean:message key="eFormGenerator.signatureFreehand"/><span>
		</div>
		<div id="Section4ba" style="display:none">
			<input type="button" name="AddSignatureBox2" id="AddSignatureBox2" style="width:400px" value="Click here, then drag a box around the signature area" onclick="SetSwitchOn('FreehandSignature');">
		</div>
		
		<% if(OscarProperties.getInstance().getBooleanProperty("eform_signature_scriptel_enabled","true")){ %>
		<!-- signature using scriptel pad -->
		<div id="Section4c"  style="display:none">
			<input type="radio" name="SignatureType" id="ScriptelSign" value="ScriptelSign" onclick="show('Section4ca'); hide('Section4aa'); hide('Section4ab'); hide('Section4ba');"><span><bean:message key="eFormGenerator.signautreScriptelPad" /><span>
		</div>
		<div id="Section4ca" style="display:none">
			<input type="button" name="AddSignatureBox3" id="AddSignatureBox3" style="width:420px" value="Click here, then drag a box to signature with scriptel pad" onclick="SetSwitchOn('ScriptelSignature');">
			<!-- <input type="radio" id="DrawScriptelSign" style="display:none"> -->
		</div>
		<%} %>
	</p>
</div>
<% } %>

<hr>
<span class='h2'>5. <bean:message key="eFormGenerator.input"/></span> <a onclick="show('Section5');"><bean:message key="eFormGenerator.expand"/></a>/<a onclick="hide('Section5');"><bean:message key="eFormGenerator.collapse"/></a></span>
<div id="Section5">
	<span class='h3'><bean:message key="eFormGenerator.inputType"/></span>
		<p>
		<input type="radio" name="inputType" id="Text" value="text" onclick="hide('SectionPrecheck');show('SectionCustomText');show('SectionDatabase');show('SectionImportMeasurements');SetSwitchOn(this.id);"><bean:message key="eFormGenerator.inputTypeText"/>
		<input type="radio" name="inputType" id="Textbox" value="textarea" onclick="hide('SectionPrecheck');show('SectionCustomText');show('SectionDatabase');show('SectionImportMeasurements');SetSwitchOn(this.id);"><bean:message key="eFormGenerator.inputTypeTextArea"/>
		<input type="radio" name="inputType" id="Checkbox" value="checkbox" onclick="show('SectionPrecheck');hide('SectionCustomText');hide('SectionDatabase');hide('SectionImportMeasurements');SetSwitchOn(this.id);"><bean:message key="eFormGenerator.inputTypeCheckbox"/>
		</p>

	<span class='h3'><bean:message key="eFormGenerator.inputAuto"/></span>
<ul style="list-style-type:none">
			<li id='SectionCustomText' style="display:block">
				<input type="radio" name="AutoPopType" id="AutoPopCustom" value="custom"><bean:message key="eFormGenerator.inputTypeCustom"/><input type="text" name="inputValue" id="inputValue" value=""></li>
			<li id='SectionDatabase' style="display:block">
				<input type="radio" name="AutoPopType" id="AutoPopDatabase" value="database"><bean:message key="eFormGenerator.inputTypeData"/>
			 <select name="oscarDB" id="oscarDB">
                                 <option value=""><bean:message key="eFormGenerator.inputTypeDataButton"/></option>
                                <%
                                  EFormLoader names = EFormLoader.getInstance();
                                  //return the array with a list of names from database
                                  List<String> kout = names.getNames();
                                for(String str :kout){ %>
                                  <option value="<%= str %>"  ><%= str %></option>
                                   <%
                                  }
                                 %>
                        </select>			</li>
			<li id="SectionImportMeasurements" style="diplay:block;">
				<input type="radio" name="AutoPopType" id="AutoPopMeasurements" value="measurements"><bean:message key="eFormGenerator.inputTypeMeasurements"/><br>
				<table>
					<tr>
						<td><p><bean:message key="eFormGenerator.inputTypeMeasurementsType"/></p></td>
						<td><p>
							<select name="MeasurementList" id="MeasurementList">
								<option value="" selected="selected"><bean:message key="eFormGenerator.inputTypeMeasurementsButton"/></option>
								<option value="HT">HT</option>
								<option value="WT">WT</option>
								<option value="BP">BP</option>
								<option value="BMI">BMI</option>
								<option value="WAIS">WAIS (waist)</option>
								<option value="WC">WC (waist circ.)</option>
								<option value="HbAi">HbAi</option>
								<option value="A1C">A1C</option>
								<option value="FBS">FBS</option>
								<option value="TG">TG</option>
								<option value="LDL">LDL</option>
								<option value="HDL">HDL</option>
								<option value="TCHD">TCHD</option>
								<option value="TCHL">TCHL</option>
								<option value="EGFR">EGFR</option>
								<option value="SCR">SCR (Cr)</option>
								<option value="ACR">ACR</option>
							</select>
							<br>
						<bean:message key="eFormGenerator.inputTypeMeasurementsCustom"/><input type="text" name="MeasurementCustom" id="MeasurementCustom" style="width:50px;">
						</p>
						</td>
						<td>
							<p><bean:message key="eFormGenerator.inputTypeMeasurementsField"/>
								<select name="MeasurementField" id="MeasurementField">
									<option value="value"><bean:message key="eFormGenerator.inputTypeMeasurementsFieldButtonValue"/></option>
									<option value="dateObserved"><bean:message key="eFormGenerator.inputTypeMeasurementsFieldButtonDateObserved"/></option>
									<option value="comments"><bean:message key="eFormGenerator.inputTypeMeasurementsFieldButtonComment"/></option>
								</select>
							</p>
						</td>
					</tr>
				</table>
			</li>
			<li id='SectionPrecheck' style="display:none">Pre-check the checkbox<input name="preCheck" id="preCheck" type="checkbox"></li>

		</ul>


	<span class='h3'><bean:message key="eFormGenerator.inputFormat"/></span>
			<p>
			<bean:message key="eFormGenerator.inputFormatFont"/>
				<select id="fontFamily">
					 <option value="sans-serif"><bean:message key="eFormGenerator.inputFormatSelectSans"/></option>
					 <option value="serif"><bean:message key="eFormGenerator.inputFormatSelectSerif"/></option>
					 <option value="monospace"><bean:message key="eFormGenerator.inputFormatSelectMono"/></option>
				</select>
			<bean:message key="eFormGenerator.inputFormatStyle"/>
				<select id="fontStyle">
					 <option value="normal"><bean:message key="eFormGenerator.inputFormatStyleNormal"/></option>
					 <option value="italic"><bean:message key="eFormGenerator.inputFormatStyleItalic"/></option>
				</select>
			<bean:message key="eFormGenerator.inputFormatWeight"/>
				<select id="fontWeight">
					 <option value="normal"><bean:message key="eFormGenerator.inputFormatStyleNormal"/></option>
					 <option value="bold"><bean:message key="eFormGenerator.inputFormatWeightBold"/></option>
					 <option value="bolder"><bean:message key="eFormGenerator.inputFormatWeightBolder"/></option>
					 <option value="lighter"><bean:message key="eFormGenerator.inputFormatWeightLighter"/></option>
				</select>
			<br>
			<bean:message key="eFormGenerator.inputFormatSize"/><input type="text" name="fontSize" id="fontSize"  style="width:50px" value="12"><bean:message key="eFormGenerator.inputFormatSizehint"/>
			<bean:message key="eFormGenerator.inputFormatAlign"/>
				<select id="textAlign">
					<option value="left"><bean:message key="eFormGenerator.inputFormatAlignLeft"/></option>
					<option value="center"><bean:message key="eFormGenerator.inputFormatAlignCenter"/></option>
					<option value="right"><bean:message key="eFormGenerator.inputFormatAlignRight"/></option>
					<option value="justify"><bean:message key="eFormGenerator.inputFormatAlignJustify"/></option>
				</select>
			</p>
			<p><bean:message key="eFormGenerator.inputFormatBackground"/>
				<select id="bgColor">
					<option value="transparent"><bean:message key="eFormGenerator.inputFormatBackgroundTransparent"/></option>
					<option value="white"><bean:message key="eFormGenerator.inputFormatBackgroundWhite"/></option>
				</select><br>
				- <bean:message key="eFormGenerator.inputFormatBackgroundhint"/>
			</p>



	<span class='h3'><bean:message key="eFormGenerator.inputName"/></span>
		<p><input type="radio" name="InputNameType" id="InputNameAuto" value="Auto" checked><bean:message key="eFormGenerator.inputNameSeq"/><br>
				- <bean:message key="eFormGenerator.inputNameSeqPrefix"/><input type="text" name="AutoNamePrefix" id="AutoNamePrefix" style="width:100px" value="AutoName"><br>
			<input type="radio" name="InputNameType" id="InputNameCustom" value="Custom"><bean:message key="eFormGenerator.inputNameSeqCustom"/>
				<input type="text" name="inputName" id="inputName">
				<br>
				- <bean:message key="eFormGenerator.inputNameSeqCustomhint1"/><br>
				- <bean:message key="eFormGenerator.inputNameSeqCustomhint2"/>
			<br>
			<input type="radio" name="InputNameType" id="InputNameMeasurement" value="Measurement"><bean:message key="eFormGenerator.inputNameMeasurement"/><br>
			<table>
				<tr>
					<td><p><bean:message key="eFormGenerator.inputNameMeasurementType"/></p></td>
					<td><p>
						<select name="ExportMeasurementList" id="ExportMeasurementList">
							<option value="" selected="selected"><bean:message key="eFormGenerator.inputNameMeasurementButton"/></option>
							<option value="HT">HT</option>
							<option value="WT">WT</option>
							<option value="BP">BP</option>
							<option value="BMI">BMI</option>
							<option value="WAIS">WAIS (waist)</option>
							<option value="WC">WC (waist circ.)</option>
							<option value="HbAi">HbAi</option>
							<option value="A1C">A1C</option>
							<option value="FBS">FBS</option>
							<option value="TG">TG</option>
							<option value="LDL">LDL</option>
							<option value="HDL">HDL</option>
							<option value="TCHD">TCHD</option>
							<option value="TCHL">TCHL</option>
							<option value="EGFR">EGFR</option>
							<option value="SCR">SCR (Cr)</option>
							<option value="ACR">ACR</option>
						</select>
						<br>
				&nbsp;<bean:message key="eFormGenerator.inputNameMeasurementsCustom"/>&nbsp;<input type="text" name="ExportMeasurementCustom" id="ExportMeasurementCustom" style="width:50px;">
					</p>
					</td>
					<td>
						<p><bean:message key="eFormGenerator.inputNameMeasurementsField"/>
							<select name="ExportMeasurementField" id="ExportMeasurementField">
								<option value="value"><bean:message key="eFormGenerator.inputTypeMeasurementsFieldButtonValue"/></option>
								<option value="dateObserved"><bean:message key="eFormGenerator.inputTypeMeasurementsFieldButtonDateObserved"/></option>
								<option value="comments"><bean:message key="eFormGenerator.inputTypeMeasurementsFieldButtonComment"/></option>
							</select>
						</p>
					</td>
				</tr>
			</table>

		</p>
	<span class='h3'><bean:message key="eFormGenerator.inputDraw"/></span>
	<br>
		<span class='h4'><bean:message key="eFormGenerator.inputDrawText"/></span>
			<p>
			- <bean:message key="eFormGenerator.inputDrawTexthint"/><br>
			</p>
		<span class='h4'><bean:message key="eFormGenerator.inputDrawCheckbox"/></span>
			<p>
			- <bean:message key="eFormGenerator.inputDrawCheckboxhint"/><br>
			</p>
	<p><input type="button" onclick="Undo();" value='<bean:message key="eFormGenerator.inputDrawUndoButton"/>'></p>
	<p><bean:message key="eFormGenerator.inputDrawhint"/></p>

</div>

<hr>
<span class='h2'>6. <bean:message key="eFormGenerator.tuning"/></span><a onclick="show('Section6');"><bean:message key="eFormGenerator.expand"/></a>/<a onclick="hide('Section6');"><bean:message key="eFormGenerator.collapse"/></a>
<div id="Section6">

<input type="button" value='<bean:message key="eFormGenerator.tuningShowButton"/>' onclick="ToggleInputName();"><br>
<table style="text-align:center; border: 1px solid black;">
	<tr>
		<td style="background-color:#dddddd;">
			<input type="button" value='<bean:message key="eFormGenerator.tuningNoneButton"/>' onclick="uncheckList('InputChecklist');"><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningAllButton"/>' onclick="checkList('InputChecklist');">
		</td>
		<td>
			<span><bean:message key="eFormGenerator.tuningUpButton"/></span><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningAlignButton"/>' style="width:100px;" onclick="alignInput('top');"><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningShiftButton"/>' style="width:100px;" onclick="changeInput('up',10);"><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningNudgeButton"/>' style="width:100px;" onclick="changeInput('up',1);">
		</td>
		<td style="background-color:#dddddd;">
			<input type="button" value='<bean:message key="eFormGenerator.tuningDeleteButton"/>' Style="width:100px;" onclick="deleteInput();">
		</td>
	</tr>
	<tr>
		<td>
			<span><bean:message key="eFormGenerator.tuningLeft"/></span><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningAlignButton"/>' style="width:50px;" onclick="alignInput('left');">
			<input type="button" value='<bean:message key="eFormGenerator.tuningShiftButton"/>' style="width:50px;" onclick="changeInput('left',10);">
			<input type="button" value='<bean:message key="eFormGenerator.tuningNudgeButton"/>' style="width:50px;" onclick="changeInput('left',1);">
		</td>
		<td style="text-align:left;">
			<ul id="InputList" name="InputList" style="list-style-type:none; list-style: none; margin-left: 0; padding-left: 1em; text-indent: -1em"></ul>
		</td>
		<td>
			<span><bean:message key="eFormGenerator.tuningRight"/></span><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningNudgeButton"/>' style="width:50px;" onclick="changeInput('right',1);">
			<input type="button" value='<bean:message key="eFormGenerator.tuningShiftButton"/>' style="width:50px;" onclick="changeInput('right',10);">
			<input type="button" value='<bean:message key="eFormGenerator.tuningAlignButton"/>' style="width:50px;" onclick="alignInput('right');">
		</td>
	</tr>
	<tr>
		<td style="background-color:#dddddd;">
			<span><bean:message key="eFormGenerator.tuningWidth"/></span><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningIncreaseButton"/>' style="width:75px;" onclick="changeInput('width',1);"><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningDecreaseButton"/>' style="width:75px;" onclick="changeInput('width',-1);">
		</td>
		<td>

			<input type="button" value='<bean:message key="eFormGenerator.tuningNudgeButton"/>' style="width:100px;" onclick="changeInput('down',1);"><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningShiftButton"/>' style="width:100px;" onclick="changeInput('down',10);"><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningAlignButton"/>' style="width:100px;" onclick="alignInput('bottom');"><br>
			<span><bean:message key="eFormGenerator.tuningDown"/></span>
			</td>
		<td style="background-color:#dddddd;">
			<span><bean:message key="eFormGenerator.tuningHeight"/></span><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningIncreaseButton"/>' style="width:75px;" onclick="changeInput('height',1);"><br>
			<input type="button" value='<bean:message key="eFormGenerator.tuningDecreaseButton"/>' style="width:75px;" onclick="changeInput('height',-1);">
		</td>
	</tr>
</table>

</div>
<hr>
<span class='h2'>7. <bean:message key="eFormGenerator.misc"/></span><a onclick="show('Section7');"><bean:message key="eFormGenerator.expand"/></a>/<a onclick="hide('Section7');"><bean:message key="eFormGenerator.collapse"/></a>
<div id="Section7">
<p><span class="h2"><bean:message key="eFormGenerator.miscMax"/></span><br>
	<input name="maximizeWindow" id="maximizeWindow" type="checkbox"><bean:message key="eFormGenerator.miscMaxhint"/>
</p>
<p><span class='h2'><bean:message key="eFormGenerator.miscCheckmarks"/></span><br>
	<input name="ScaleCheckmark" id="ScaleCheckmark" type="checkbox"><bean:message key="eFormGenerator.miscCheckmarksScale"/><br>
	<input name="DefaultCheckmark" id="DefaultCheckmark" type="checkbox"><bean:message key="eFormGenerator.miscCheckmarksDraw"/>
</p>
<% if (OscarProperties.getInstance().isPropertyActive("eform_generator_indivica_fax_enabled")) { %>
<p><span class='h2'><bean:message key="eFormGenerator.fax"/></span><br>
	<input name="includeFaxControl" id="includeFaxControl" type="checkBox"><bean:message key="eFormGenerator.faxDescription"/>
</p>
<% } %>
</div>
<hr>
<span class='h2'>8. <bean:message key="eFormGenerator.generate"/></span><a onclick="show('Section8');"><bean:message key="eFormGenerator.expand"/></a>/<a onclick="hide('Section8');"><bean:message key="eFormGenerator.collapse"/></a>
<div id='Section8'>
<!-- Inject the html to the eForm window -->
		<input name="loadHTMLButton" id="loadHTMLButton" type="button" value='<bean:message key="eFormGenerator.generateLoadButton"/>' onClick="injectHtml();">
	<input name="reset" id="reset" type="button" value='<bean:message key="eFormGenerator.generateResetButton"/>' onclick="resetAll();">
<!--  Cookie Monster says hello! -->
	<input name="save" id="save" type="button" value='<bean:message key="eFormGenerator.generateSaveButton"/>' onclick="save_to_cookie();">
	<input name="restore" id="restore" type="button" value='<bean:message key="eFormGenerator.generateRestoreSaveButton"/>' onclick="restoreSaved();">
<!--  Cookie Monster says bye! -->
	<p>- <bean:message key="eFormGenerator.generatehint1"/>
                <br>- <bean:message key="eFormGenerator.generatehint2"/>
		<br>- <bean:message key="eFormGenerator.generatehint3"/>
                <br>- <bean:message key="eFormGenerator.generatehint4"/>
	</p>

</div>

</div>
</form>

<!--  Drawing code: start -->
<div id="preview" name="preview" style="position: absolute; left: 0px; top: 0px;"></div>
<div id="myCanvas" name="myCanvas" style="position: absolute; left: 0px; top: 0px;"></div>

<script type="text/javascript">
var DrawData = new Array();
var TempData = new Array();

var cnv = document.getElementById("myCanvas");
var jg = new jsGraphics(cnv);

var pvcnv = document.getElementById("preview");
var pv = new jsGraphics(pvcnv);

jg.setPrintable(true);
var StrokeColor = "red";
var StrokeThickness = 2;
var x0 = 0;
var y0 = 0;
var ShowInputName = false;

function clearGraphics(canvas){
	canvas.clear();
}

function SetStrokeColor(c){
	StrokeColor = c;
}

var MouseDown = false;
function SetMouseDown(){
	MouseDown = true;
}
function SetMouseUp(){
	MouseDown = false;
}

var DrawSwitch = false;

function SetDrawOn(){
	DrawSwitch = true;
}
function SetDrawOff(){
	DrawSwitch  = false;
}

var TextSwitch = true;
var TextboxSwitch = false;
var CheckboxSwitch = false;
var MaleSwitch = false;
var FemaleSwitch = false;
var SignatureBoxSwitch = false;
var ScriptelSignature = false;
var FreehandSignature = false;
var IndivicaSignatureSwitch = false;
function SetSwitchesOff(){
	TextSwitch = false;
	TextboxSwitch = false;
	CheckboxSwitch = false;
	MaleSwitch = false;
	FemaleSwitch = false;
	SignatureBoxSwitch = false;
	IndivicaSignatureSwitch = false;
	ScriptelSignature = false;
	ScriptelSignature = false;
}

var DrawTool = "Text";

function SetSwitchOn(n){
	SetSwitchesOff();
	DrawTool = n;

	if (n=="Text"){
		TextSwitch = true;
	}else if (n=="Textbox"){
		TextboxSwitch = true;
	}else if(n=="Checkbox"){
		CheckboxSwitch = true;
	}else if (n=="Male"){
		MaleSwitch = true;
	}else if (n=="Female"){
		FemaleSwitch = true;
	}else if (n=="SignatureBox"){
		SignatureBoxSwitch = true;
	}else if (n=="ScriptelSignature"){
		ScriptelSignature = true;
	}else if (n=="IndivicaSignature") {
		IndivicaSignatureSwitch = true;
	} else if (n == "FreehandSignature") {
		FreehandSignature = true;
	}
}


function SetStart(){
	x0 = parseInt(mousex);	//assign x coordinate at mousedown to x0
	y0 = parseInt(mousey);	//assign y coordinate at mousedown to y0
}

function DrawText(canvas,x0,y0,width,height,inputName,fontFamily,fontStyle,fontWeight,fontSize,textAlign,bgColor,oscarDB,inputValue){
	// draw Rectangle
	var x0 = parseInt(x0);
	var y0 = parseInt(y0);
	var width = parseInt(width);
	var height = parseInt(height);
	canvas.setColor(StrokeColor);
	canvas.setStroke(StrokeThickness);
	canvas.drawRect(x0,y0,width,height);
	canvas.paint();
	if (ShowInputName){
		canvas.setColor('blue');
		canvas.setFont("sans-serif","10px",Font.BOLD);
		var xt = x0 + StrokeThickness
		var yt = y0 + StrokeThickness
		canvas.drawString(inputName,xt,y0);
		canvas.paint();
		canvas.setColor(StrokeColor);
	}

	//store parameters in an array (using separator "|")
	if (canvas == jg){
		var Parameter = "Text" + "|" + x0 + "|" + y0 + "|" + width + "|" + height + "|" + inputName + "|" + fontFamily + "|" + fontStyle + "|" + fontWeight + "|" + fontSize + "|" + textAlign + "|" + bgColor + "|" + oscarDB + "|" + inputValue;
		DrawData.push(Parameter);
	}
}

function DrawTextbox(canvas,x0,y0,width,height,inputName,fontFamily,fontStyle,fontWeight,fontSize,textAlign,bgColor,oscarDB,inputValue){
	// draws Rectangle
	var x0 = parseInt(x0);
	var y0 = parseInt(y0);
	var width = parseInt(width);
	var height = parseInt(height);
	canvas.setColor(StrokeColor);
	canvas.setStroke(StrokeThickness);
	canvas.drawRect(x0,y0,width,height);
	canvas.paint()
	if (ShowInputName){
		canvas.setColor('blue');
		canvas.setFont("sans-serif","10px",Font.BOLD);
		var xt = x0 + StrokeThickness
		var yt = y0 + StrokeThickness
		canvas.drawString(inputName,xt,y0);
		canvas.paint();
		canvas.setColor(StrokeColor);
	}
	//store parameters in an array (using separator "|")
	if (canvas == jg){
		var Parameter = "Textbox" + "|" + x0 + "|" + y0 + "|" + width + "|" + height + "|" + inputName + "|" + fontFamily + "|" + fontStyle + "|" + fontWeight + "|" + fontSize + "|" + textAlign + "|" + bgColor + "|" + oscarDB + "|" + inputValue;
		DrawData.push(Parameter);
	}
}

function DrawCheckbox(canvas,x0,y0,inputName,preCheck){
	// draws Checkbox
	var x = parseInt(x);
	var y = parseInt(y);
	canvas.setColor(StrokeColor);
	canvas.setStroke(StrokeThickness);
	var s = 10; 	//square with side of 10
	canvas.drawRect(x0,y0,s,s);
	canvas.paint();
	if (ShowInputName){
		canvas.setColor('blue');
		canvas.setFont("sans-serif","10px",Font.BOLD);
		var xt = x0 + StrokeThickness
		var yt = y0 + StrokeThickness
		canvas.drawString(inputName,xt,y0);
		canvas.paint();
		canvas.setColor(StrokeColor);
	}
	canvas.paint();
	//store parameters in an array (using separator "|")
	if (canvas == jg){
		var Parameter = "Checkbox" + "|" + x0 + "|" + y0 + "|" + inputName + "|" + preCheck;
		DrawData.push(Parameter);
	}
}

function DrawMale(canvas,x0,y0){
	// draws Checkbox
	canvas.setColor(StrokeColor);
	canvas.setStroke(StrokeThickness);
	var s = 10;  //s = lenght of side of square
	canvas.drawRect(x0,y0,s,s);
	canvas.paint();
	if (ShowInputName){
		canvas.setColor('blue');
		canvas.setFont("sans-serif","10px",Font.BOLD);
		var xt = x0 + StrokeThickness
		var yt = y0 + StrokeThickness
		canvas.drawString("Male",xt,y0);
		canvas.paint();
		canvas.setColor(StrokeColor)
	}

	//assigns coordinates of top left corner of checkbox
	MTopLeftX = x0;
	MTopLeftY = y0;

	//reset to default text input
	SetSwitchOn('Text');
	document.getElementById('Text').checked = true;

}

function DrawFemale(canvas,x0,y0){
	// draws Checkbox
	canvas.setColor(StrokeColor);
	canvas.setStroke(StrokeThickness);
	var s = 10;
	canvas.drawRect(x0,y0,s,s);
	canvas.paint();

	if (ShowInputName){
		canvas.setColor('blue');
		canvas.setFont("sans-serif","10px",Font.BOLD);
		var xt = x0 + StrokeThickness
		var yt = y0 + StrokeThickness
		canvas.drawString("Female",xt,y0);
		canvas.paint();
		canvas.setColor(StrokeColor);
	}

	//assigns coordinates of top left corner of checkbox
	FTopLeftX = x0;
	FTopLeftY = y0;
	//reset to default text input
	SetSwitchOn('Text');
	document.getElementById('Text').checked = true;

}

function DrawSignatureBox(canvas, x0, y0, width, height){
	//draws box
	var div4ba = document.getElementById("Section4ba");
	canvas.setColor(StrokeColor);
	canvas.setStroke(StrokeThickness);
	canvas.drawRect(x0,y0,width,height);
	canvas.paint();

	if(ShowInputName){
		canvas.setColor('blue');
		canvas.setFont("sans-serif","10px",Font.BOLD);
		var xt = x0 + StrokeThickness
		var yt = y0 + StrokeThickness
		canvas.drawString("SignatureBox",xt,y0);
		canvas.paint();
		canvas.setColor(StrokeColor);
	}
	//assigns coordinates of top left corner of box
	SignatureHolderX = x0;
	SignatureHolderY = y0;
	SignatureHolderW = width;
	SignatureHolderH = height;

	//reset to default input of text input
	SetSwitchOn('Text');
	document.getElementById('Text').checked = true;
}

function DrawScriptelInputBox(canvas, x0, y0, width, height, inputName){
	//draws box
	var div4ca = document.getElementById("Section4ca");
	if (div4ca != null) {
		// in order to do mapping size for scriptel drawing picture
		if (width > 500 && height > 100) {
			width = 500;
			height = 100;
		} else if (width > 500) {
			width = height * 5;
		} else if (height > 100) {
			height = width / 5;
		} else {
			if (width * 100000 / height > 5 * 100000) { // more widder
				width = height * 5;
			} else {
				height = Math.round(width / 5);
			}
		}
	}
	
	canvas.setColor(StrokeColor);
	canvas.setStroke(StrokeThickness);
	canvas.drawRect(x0,y0,width,height);
	canvas.paint();
	
	if (ShowInputName){
		canvas.setColor('blue');
		canvas.setFont("sans-serif","10px",Font.BOLD);
		var xt = x0 + StrokeThickness
		var yt = y0 + StrokeThickness
		canvas.drawString(inputName,xt,y0);
		canvas.paint();
		canvas.setColor(StrokeColor);
	}
	//assigns coordinates of top left corner of box
	//SignatureHolderX1 = x0;
	//SignatureHolderY1 = y0;
	//SignatureHolderW1 = width;
	//SignatureHolderH1 = height;
	
	//reset to default input of text input
	SetSwitchOn('Text');
	document.getElementById('Text').checked = true;
	
	if (canvas == jg){
		var Parameter = scriptelSigBox + "|" + x0 + "|" + y0 + "|" + width + "|" + height + "|" + inputName;
		DrawData.push(Parameter);
	}
}

function DrawFreehandInputBox(canvas, x0, y0, width, height, inputName){

	canvas.setColor(StrokeColor);
	canvas.setStroke(StrokeThickness);
	canvas.drawRect(x0,y0,width,height);
	canvas.paint();
	
	if (ShowInputName){
		canvas.setColor('blue');
		canvas.setFont("sans-serif","10px",Font.BOLD);
		var xt = x0 + StrokeThickness
		var yt = y0 + StrokeThickness
		canvas.drawString(inputName,xt,y0);
		canvas.paint();
		canvas.setColor(StrokeColor);
	}
	
	//reset to default input of text input
	SetSwitchOn('Text');
	document.getElementById('Text').checked = true;
	
	if (canvas == jg){
		var Parameter = freehandSigBox + "|" + x0 + "|" + y0 + "|" + width + "|" + height + "|" + inputName;
		DrawData.push(Parameter);
	}
}


var inputName="";
var inputCounter = 1;


function DrawMarker(){
	var x = parseInt(mousex);	//assign x coordinate at mouseup to x
	var y = parseInt(mousey);	//assign y coordinate at mouseup to y


	var width = x - x0;
	var height = y - y0;
	var fontFamily = document.getElementById('fontFamily').value;
	var fontStyle = document.getElementById('fontStyle').value;
	var fontWeight = document.getElementById('fontWeight').value;
	var fontSize = document.getElementById('fontSize').value;
	var textAlign = document.getElementById('textAlign').value;
	var bgColor = document.getElementById('bgColor').value;

	//get value of autopopulating data
	var preCheck = document.getElementById('preCheck').checked
	var inputValue = "";
	var oscarDB = "";
	var AutoPopType = getCheckedValue(document.getElementsByName('AutoPopType'));
	if (AutoPopType == 'custom'){
		inputValue = document.getElementById('inputValue').value;
	}else if (AutoPopType == 'database'){
		oscarDB = document.getElementById('oscarDB').value;
	}else if (AutoPopType == 'measurements'){
		if (document.getElementById('MeasurementList').value){	// Common Standard MeasurementTypes
			oscarDB = "m$" + document.getElementById('MeasurementList').value + "#" + document.getElementById('MeasurementField').value;
		}else if (document.getElementById('MeasurementCustom').value){	//Custom Measurement Types
			oscarDB = "m$" + document.getElementById('MeasurementCustom').value + "#" + document.getElementById('MeasurementField').value;
		}
	}

	//get name of input field
	var inputNameType = getCheckedValue(document.getElementsByName('InputNameType'));  // inputNameType = Auto/Custom
	if (inputNameType == "Custom"){
		e = document.getElementById('inputName').value
		if (e){
			inputName = e
		} else if (!e){
			alert('Please enter in a value for the custom input name field');	//reminds user to put in mandatory name for input field
			return false;
		}
	} else if(inputNameType == "Measurement"){
		if (document.getElementById('ExportMeasurementList').value){
			inputName = "m$" + document.getElementById('ExportMeasurementList').value + "#" + document.getElementById('ExportMeasurementField').value;
		}else if (document.getElementById('ExportMeasurementCustom').value){
			inputName = "m$" + document.getElementById('ExportMeasurementCustom').value + "#" + document.getElementById('ExportMeasurementField').value;
		}
	}else if (inputNameType == "Auto") {
		if (oscarDB){
			inputName = oscarDB;	//if auto-naming input fields, use oscarDB tag if available
			var InputList = document.getElementsByName('InputChecklist');
			var j = 0;
			for (i=0; i < InputList.length; i++){
				var InputItem = InputList[i].value.substring(0,inputName.length);	//add increment to oscarDB name if repeated
				if (InputItem == inputName){
				 j++;
				}
			}
			if (j>0){
				inputName = inputName + j;
			}
		}else{
			inputName = document.getElementById('AutoNamePrefix').value + inputCounter;
			++inputCounter;
		}
	}
	//compare inputName to list of existing inputNames to ensure unique names
	for (i=0; i < document.getElementsByName('InputChecklist').length; i++){
		var InputItem = document.getElementsByName('InputChecklist')[i].value;
		if (inputName == InputItem){
			alert('Name already in use, please enter in another UNIQUE input name');
		}
	}


	if(DrawSwitch){
		if (TextSwitch){
			DrawText(jg,x0,y0,width,height,inputName,fontFamily,fontStyle,fontWeight,fontSize,textAlign,bgColor,oscarDB,inputValue);
		}else if (TextboxSwitch){
			DrawTextbox(jg,x0,y0,width,height,inputName,fontFamily,fontStyle,fontWeight,fontSize,textAlign,bgColor,oscarDB,inputValue);
		}else if (CheckboxSwitch){
			DrawCheckbox(jg,x0,y0,inputName,preCheck);
		}else if(MaleSwitch){
			DrawMale(jg,x0,y0);
		}else if(FemaleSwitch){
			DrawFemale(jg,x0,y0);
		}else if(ScriptelSignature){
			DrawScriptelInputBox(jg,x0,y0,width,height,scriptelSigBox + inputCounter);
		}else if(FreehandSignature) {
			DrawFreehandInputBox(jg,x0,y0,width,height,freehandSigBox + inputCounter);
		}else if (SignatureBoxSwitch || IndivicaSignatureSwitch ){
			DrawSignatureBox(jg,x0,y0,width,height);
		}
	}

	//reset input data
	document.getElementById('inputValue').value = "";
	document.getElementById('inputName').value = "";
	document.getElementById('bgColor')[0].selected = true;
	document.getElementById('preCheck').checked = false;
	document.getElementById('oscarDB')[0].selected = true;
	document.getElementById('MeasurementList')[0].selected = true;
	document.getElementById('ExportMeasurementList')[0].selected = true;
	document.getElementById('MeasurementCustom').value = "";
	document.getElementById('ExportMeasurementCustom').value = "";

}

function ToggleInputName(){
	jg.clear();
	if (ShowInputName){
		ShowInputName = false;
	} else if (!ShowInputName){
		ShowInputName = true;
	}
	drawPageOutline();
	TempData = DrawData;
	DrawData = new Array();
	for (j=0; (j < (TempData.length) ); j++){
		var RedrawParameter = TempData[j].split("|");
		RedrawImage(RedrawParameter);
	}
	if (document.getElementById('preCheckGender').checked){
		DrawMale(jg,MTopLeftX,MTopLeftY);
		DrawFemale(jg,FTopLeftX,FTopLeftY);
	}
	if (document.getElementById('AddSignature').checked) {
		DrawSignatureBox(jg,SignatureHolderX,SignatureHolderY,SignatureHolderW,SignatureHolderH);
	}
}

function RedrawAll(){
	jg.clear();

	drawPageOutline();
	TempData = DrawData;
	DrawData = new Array();
	for (j=0; (j < (TempData.length) ); j++){
		var RedrawParameter = TempData[j].split("|");
		RedrawImage(RedrawParameter);
	}
	if (document.getElementById('preCheckGender').checked){
		DrawMale(jg,MTopLeftX,MTopLeftY);
		DrawFemale(jg,FTopLeftX,FTopLeftY);
	}
	if (document.getElementById('AddSignature').checked){
		DrawSignatureBox(jg,SignatureHolderX,SignatureHolderY,SignatureHolderW,SignatureHolderH);
	}
}

function Undo(){
	jg.clear();
	TempData = DrawData;
	DrawData = new Array();

	drawPageOutline();
	for (j=0; (j < (TempData.length - 1) ); j++){
		var RedrawParameter = TempData[j].split("|");
		RedrawImage(RedrawParameter);
	}
	var inputNameType = getCheckedValue(document.getElementsByName('InputNameType'));  // inputNameType = Auto/Custom
	if (inputNameType == "Auto") {
		--inputCounter;
	}
}

function RedrawImage(RedrawParameter){
	var InputType = RedrawParameter[0];
	if(InputType == "Text"){
		var x0 = parseInt(RedrawParameter[1]);
		var y0 = parseInt(RedrawParameter[2]);
		var width = parseInt(RedrawParameter[3]);
		var height = parseInt(RedrawParameter[4]);
		var inputName = RedrawParameter[5];
		var fontFamily = RedrawParameter[6];
		var fontStyle = RedrawParameter[7];
		var fontWeight = RedrawParameter[8];
		var fontSize = RedrawParameter[9];
		var textAlign = RedrawParameter[10];
		var bgColor = RedrawParameter[11];
		var oscarDB = RedrawParameter[12];
		var inputValue = RedrawParameter[13];
		DrawText(jg,x0,y0,width,height,inputName,fontFamily,fontStyle,fontWeight,fontSize,textAlign,bgColor,oscarDB,inputValue);
	}else if (InputType == "Textbox"){
		var x0 = parseInt(RedrawParameter[1]);
		var y0 = parseInt(RedrawParameter[2]);
		var width = parseInt(RedrawParameter[3]);
		var height = parseInt(RedrawParameter[4]);
		var inputName = RedrawParameter[5];
		var fontFamily = RedrawParameter[6];
		var fontStyle = RedrawParameter[7];
		var fontWeight = RedrawParameter[8];
		var fontSize = RedrawParameter[9];
		var textAlign = RedrawParameter[10];
		var bgColor = RedrawParameter[11];
		var oscarDB = RedrawParameter[12];
		var inputValue = RedrawParameter[13];
		DrawTextbox(jg,x0,y0,width,height,inputName,fontFamily,fontStyle,fontWeight,fontSize,textAlign,bgColor,oscarDB,inputValue);
	}else if (InputType == "Checkbox"){
		var x0 = parseInt(RedrawParameter[1]);
		var y0 = parseInt(RedrawParameter[2]);
		var inputName = RedrawParameter[3];
		var preCheck = RedrawParameter[4];
		DrawCheckbox(jg,x0,y0,inputName,preCheck);
	} else if (InputType == scriptelSigBox || InputType == freehandSigBox) {
		var x0 = parseInt(RedrawParameter[1]);
		var y0 = parseInt(RedrawParameter[2]);
		var width = parseInt(RedrawParameter[3]);
		var height = parseInt(RedrawParameter[4]);
		var inputName = RedrawParameter[5];
		if (InputType == scriptelSigBox) {
			DrawScriptelInputBox(jg, x0, y0, width, height, inputName);
		} else {
			DrawFreehandInputBox(jg, x0, y0, width, height, inputName);
		}
	}
}

function drawPortraitOutline(){
	jg.setColor('red');
	jg.setStroke(StrokeThickness);
	jg.drawRect(0,0,750,1000);
	jg.paint();
}
function drawLandscapeOutline(){
	jg.setColor('red');
	jg.setStroke(StrokeThickness);
	jg.drawRect(0,0,1000,750);
	jg.paint();
}
<!-- Drawing code ends -->
</script>
<!--  Cookie Monster says hello! -->
<script type="text/javascript">
function getCookie (name) {
    var dc = document.cookie;
    var cname = name + "=";

    if (dc.length > 0) {
      begin = dc.indexOf(cname);
      if (begin != -1) {
        begin += cname.length;
        end = dc.indexOf(";" ,begin);
        if (end == -1) end = dc.length;
        return dc.substring(begin, end);
        }
      }
    return null;
}
function save_to_cookie(){
var exp = new Date();
exp.setTime(exp.getTime() + (1000 * 60 * 60 * 24 * 30));
document.cookie = "drawdata" + "=" + DrawData + "; expires=" + exp.toGMTString() + "; path=/";
document.cookie = "inputcounter" + "=" + inputCounter + "; expires=" + exp.toGMTString() + "; path=/";
}
function restoreSaved(){
DrawData=getCookie("drawdata").split(",");
inputCounter=getCookie("inputcounter");
RedrawAll();
}
</script>
<!--  Cookie Monster says bye! -->
</body>
</html>
