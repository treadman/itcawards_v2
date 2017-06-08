<cfoutput>
<cfif isDefined("form.dupeList") AND form.dupeList NEQ thisDupeList AND ListLen(form.dupeList) GT 0>
	<input type="hidden" name="dupeList" value="#form.dupeList#">
	<cfloop from="1" to="#ListLen(form.dupeList)#" index="thisPos">
		<input type="hidden" name="dupe_#thisPos#" value="#evaluate('form.dupe_#thisPos#')#">
	</cfloop>
<cfelse>
	<input type="hidden" name="dupeList" value="#thisDupeList#">
</cfif>
</cfoutput>
</form>
