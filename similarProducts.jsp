<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*, java.text.DecimalFormat"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Similar Products</title>
</head>
<%Connection conn = null;
  ResultSet rs = null;
  Statement stmt = null;
	try {
		Class.forName("org.postgresql.Driver");
		String url = "jdbc:postgresql://159.203.253.157/marketPA2";
    	String admin = "ltindall";
    	String password = "P3anutNJ3lly";
		conn = DriverManager.getConnection(url, admin, password);
		
		String uberQuery = "WITH pValues AS ( "+ 
				"SELECT SUM(quantity*price) AS spent, product_id, user_id FROM "+
				" orders GROUP BY user_id, product_id ORDER BY user_id) "+
				"SELECT (top.cosSim/(n1.norm*n2.norm)) AS result,prod1.name AS prodA,prod2.name AS prodB FROM "+
				"(SELECT SUM(quantity*price) AS norm, product_id FROM orders GROUP BY product_id ORDER BY product_id) AS n1 "+
				"JOIN (SELECT SUM(t1.spent * t2.spent) AS cosSim,t1.product_id AS p1,t2.product_id AS p2 FROM "+
				"pValues AS t1 JOIN pValues AS t2 ON t1.user_id=t2.user_id AND t1.product_id < t2.product_id GROUP BY t1.product_id,t2.product_id) AS top "+
				"ON n1.product_id=p1 JOIN (SELECT SUM(quantity*price) AS norm, product_id FROM orders GROUP BY product_id ORDER BY product_id) AS n2 "+
				"ON n2.product_id=p2 JOIN products prod1 ON prod1.id=top.p1 JOIN "+
				"products prod2 ON top.p2=prod2.id "+
				"ORDER BY result DESC LIMIT 100;";
		stmt = conn.createStatement();
		long startTime = System.currentTimeMillis();
		rs = stmt.executeQuery(uberQuery);
		long endTime = System.currentTimeMillis();
%>
<body>
<h1>Similar Products</h1>
Hello <%=session.getAttribute("user_name")%>

<table border="1">
<tr><td>Index</td><td>Normalized Result</td><td>Product A</td><td>Product B</td></tr>
<% 
		int count = 0;
		DecimalFormat df = new DecimalFormat("#.000000");
		out.print("<br>Query time: " + ((double)(endTime - startTime))/1000 + " seconds<br>");
		while(rs.next()){
		out.print("<tr><td>"+ ++count+"</td><td>"+df.format(rs.getDouble("result"))+"</td><td>" 
			  	  +rs.getString("prodA")+"</td><td>"+rs.getString("prodB")+"</td></tr>");
		}

	}
	catch (SQLException e) {
		throw new RuntimeException(e);
	}
	finally{
		if (rs != null) {
	    	try {
	        	rs.close();
	        } catch (SQLException e) { } // Ignore
	        rs = null;
	    }
		if (stmt != null) {
	    	try {
	        	stmt.close();
	        } catch (SQLException e) { } // Ignore
	        stmt = null;
	    }
	    if (conn != null) {
	    	try {
	        	conn.close();
	        } catch (SQLException e) { } // Ignore
	        conn = null;
	    }
	}
%>
</table>
</body>
</html>