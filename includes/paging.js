function openURL()
{ 

selInd = document.pageform.pageselect.selectedIndex; 

goURL = document.pageform.pageselect.options[selInd].value;

top.location.href = goURL; 

}