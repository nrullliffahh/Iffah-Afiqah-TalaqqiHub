<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String portalTab = (String) request.getAttribute("portalTab");
    if (portalTab == null || portalTab.trim().isEmpty()) {
        portalTab = request.getParameter("portalTab");
    }
    if (portalTab == null) portalTab = "";
    portalTab = portalTab.trim().toLowerCase();
%>
<script>
(function (w) {
    var portal = "<%= portalTab.replace("\"", "\\\"") %>";
    if (portal) {
        try { w.sessionStorage.setItem("talaqqiPortal", portal); } catch (e) {}
    }
    if (w.__talaqqiFetchPatched) return;
    w.__talaqqiFetchPatched = true;
    var nativeFetch = w.fetch.bind(w);
    w.fetch = function (input, init) {
        init = init || {};
        if (!init.credentials) init.credentials = "same-origin";
        var tabPortal = portal;
        try {
            if (!tabPortal) tabPortal = w.sessionStorage.getItem("talaqqiPortal") || "";
        } catch (e) {}
        if (tabPortal) {
            var headers = new w.Headers(init.headers || {});
            headers.set("X-Talaqqi-Portal", tabPortal);
            init.headers = headers;
        }
        return nativeFetch(input, init);
    };
})(window);
</script>
