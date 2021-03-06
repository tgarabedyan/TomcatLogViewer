<%-- 
    Document   : index
    Created on : 22.12.2021 г., 15:15:22 ч.
    Author     : tgarabedyan
--%>

<%@page import="com.geministudio.CatalinaLogFormatter"%>
<%@page import="com.geministudio.AccessLogFormatter"%>
<%@page import="org.apache.catalina.valves.AccessLogValve"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.*"%>
<%@page import="org.apache.jasper.tagplugins.jstl.core.ForEach"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Tomcat Log Viewer</title>
        <link rel="stylesheet" href="styles.css"/>
    </head>
    <body>
            <div id="box" class="curved container">
                <img id="my-logo" src="logo.png" alt="[logo]" />
                <img id="tomcat-logo" src="tomcat.svg" alt="[tomcat logo]" />                
                <span style="margin-left: 20pt;">
                    <h1>Tomcat Log Viewer</h1>
                    <h2>by Gemini Studio</h2>
                </span>
            </div>
        <form action="index.jsp">
            <label for="log_group">Available logs:</label>
            <select id="log_group" name="log_group" onchange="submit()">
                <option value="*">-</option>
                <%
                    String selectedGroup = request.getParameter("log_group");
                    String selectedDate = request.getParameter("log_date");
                    ArrayList<String> listGroup = new ArrayList<>();
                    String root = System.getProperty("catalina.base") + "/logs";
                    File rootDir = new File(root);

                    if (rootDir.isDirectory()) {
                        for (File f : rootDir.listFiles()) {
                            String[] parts = f.getName().split("\\.");
                            if (parts.length > 0 && !listGroup.contains(parts[0]) && f.isFile()) {
                                listGroup.add(parts[0]);
                            }
                        }
                        for (String g : listGroup) {
                            out.print("<option value=\"" + g + "\"");
                            if (g.equalsIgnoreCase(selectedGroup)) {
                                out.print(" selected>");
                            } else {
                                out.print(">");
                            }
                            out.println(g + "</option>");
                        }
                    }
                %>
            </select>

            <label for="log_date">For date:</label>
            <select id="log_date" name="log_date" onchange="submit()">
                <option value="*">-</option>            
                <%
                    ArrayList<String> listDates = new ArrayList<>();
                    if (!"*".equals(selectedGroup) && !"".equals(selectedGroup)) {
                        for (File f : rootDir.listFiles()) {
                            String[] parts = f.getName().split("\\.");
                            if (parts.length > 1 && parts[0].equals(selectedGroup) && !listDates.contains(parts[1])) {
                                listDates.add(parts[1]);
                            }
                        }
                        for (String g : listDates) {
                            out.print("<option value=\"" + g + "\"");
                            if (g.equalsIgnoreCase(selectedDate)) {
                                out.print(" selected>");
                            } else {
                                out.print(">");
                            }
                            out.println(g + "</option>");
                        }
                    }
                %>
            </select>
            <input type="submit" value="Reload" class="button">
        </form>
        <p></p>
                <%
                    if (selectedGroup != null && selectedDate != null && !"*".equals(selectedGroup) && !"*".equals(selectedDate)) {
                        for (File f : rootDir.listFiles()) {
                            if (f.getName().startsWith(selectedGroup + "." + selectedDate)) {
                                out.println("<div id=\"logContent\" style=\"overflow: scroll; height: 480px;\">");
                                out.println("<table style=\"border-collapse:collapse; border: none;\">");
                                
                                BufferedReader reader = new BufferedReader(new FileReader(f));
                                String line = "";
                                int row = 0;
                                boolean isAccessLog = selectedGroup.contains("access");
                                boolean isCatalinaLog = selectedGroup.contains("catalina") || selectedGroup.contains("manager");
                                AccessLogFormatter accessFormatter = new AccessLogFormatter();
                                CatalinaLogFormatter catalinaFormatter = new CatalinaLogFormatter();
                                if (isAccessLog) {
                                    out.println("<thead>"+AccessLogFormatter.TableHeader+"</thead>");
                                } else if (isCatalinaLog) {
                                    out.println("<thead>"+CatalinaLogFormatter.TableHeader +"</thead>");
                                }
                                out.println("<tbody>");
                                while ((line = reader.readLine()) != null) {
                                    if (line.length() < 1) {
                                        continue;
                                    }
                                    row++;
                                    if (isAccessLog)
                                        out.println(accessFormatter.formatAsHtml(line, (row%2==0?"even":"odd")));
                                    else if (isCatalinaLog)
                                        out.println(catalinaFormatter.formatAsHtml(line, (row%2==0?"even":"odd")));
                                    else {
                                        if (row % 2 == 0) {
                                            out.print("<tr class=\"even");
                                        } else {
                                            out.print("<tr class=\"odd");
                                        }
                                        if (line.contains("WARNING")) {
                                            out.print(" warning");
                                        }
                                        if (line.contains("SEVERE")) {
                                            out.print(" severe");
                                        }
                                        //out.println(line.substring(0, Math.min(120, line.length()))+"</td></tr>");
                                        out.println("\"><td>" + line + "</td></tr>");
                                    }
                                }
                                out.println("</tbody></table></div>");
                            }
                        }
                    }
                %>
    <br class="separator" />
    <p class="copyright">Version 1.0 is provided under GPL by Toni Garabedyan. &copy;2022</p>
    </body>
</html>
