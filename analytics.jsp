<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<title>CSE135 Project</title>
<%-- <link href="css/style.css" rel="stylesheet"> --%>
</head>

<%
	Connection conn = null;
	try {
		Class.forName("org.postgresql.Driver");
		String url = "jdbc:postgresql://159.203.253.157/marketPA2";
                String admin = "ltindall";
	        String password = "P3anutNJ3lly";
                conn = DriverManager.getConnection(url, admin, password);
	}
	catch (Exception e) {}

        int category = 0;

  ResultSet rs = null;
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		//String action = request.getParameter("submit");

            // row option for query
            String rowOption = request.getParameter("row");

            // order option for query
            String orderOption = request.getParameter("order");

            // category id for query, if all categories then it equals 0
            category = Integer.parseInt(request.getParameter("category"));

            Statement stmt = conn.createStatement(
              ResultSet.TYPE_SCROLL_INSENSITIVE,
              ResultSet.TYPE_SCROLL_INSENSITIVE
            );
          	// ResultSet rs = stmt.executeQuery("SELECT p.id, p.name, p.sku, p.price, c.name as category_name" +
          	// 	" FROM products p, categories c where is_delete = false and c.id = p.category_id");

            //currently this query is not dynamic: it only does customers, alphabetical, all
            rs = stmt.executeQuery("SELECT k.userid, k.username, k.totaluser, k.prodid, k.prodname, k.totalprod, COALESCE(SUM(o.price * o.quantity),0) AS spent " +
            "FROM (SELECT p.id AS prodId, p.name AS prodName, p.totalprod, u.id AS userId, u.name AS username, u.totaluser " +
            "FROM (SELECT * FROM ( " +
          	       "SELECT p3.id, p3.name, COALESCE(SUM(o.price * o.quantity),0) AS totalProd " +
          	       "FROM Products p3 LEFT JOIN Orders o ON p3.id = o.product_id " +
          	       "WHERE (o.is_cart = false OR o.is_cart IS NULL) " + //AND category_id = 2
          	       "GROUP BY p3.id, p3.name " +
          	       "ORDER BY p3.name ASC " +
            ") p2 OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY) p, " +
                   "(SELECT * FROM ( " +
          	       "SELECT u3.id, u3.name, COALESCE(SUM(o.price * o.quantity),0) AS totalUser " +
          	       "FROM Users u3 LEFT JOIN Orders o ON u3.id = o.user_id " +
          	       "WHERE o.is_cart = false OR o.is_cart IS NULL " +
          	       "GROUP BY u3.id, u3.name " +
          	       "ORDER BY u3.name ASC " +
            ") u2 OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY) u " +
            ") k LEFT JOIN (SELECT * FROM Orders o2 WHERE o2.is_cart = false) o ON k.userid = o.user_id AND k.prodid = o.product_id " +
            "GROUP BY k.userid, k.username, k.totaluser, k.prodid, k.prodname, k.totalprod " +
            "ORDER BY k.username ASC, k.prodname ASC " +
            "");

	}



        Statement catStmt = conn.createStatement();
        ResultSet categories = catStmt.executeQuery("SELECT c.id,c.name FROM categories c");
%>
<body>
<div class="collapse navbar-collapse">
	<ul class="nav navbar-nav">
		<li><a href="index.jsp">Home</a></li>
		<li><a href="categories.jsp">Categories</a></li>
		<li><a href="products.jsp">Products</a></li>
		<li><a href="orders.jsp">Orders</a></li>
		<li><a href="login.jsp">Logout</a></li>
	</ul>
</div>
<div class="container">
    <div class="row">
        <form  class="form-inline" action="analytics.jsp" method="POST">
            <div class="form-group">
                <label for="row">Row</label>
                <select class="form-control" id="row" name="row">
                    <option>Customers</option>
                    <option>States</option>
                </select>
            </div>
            <div class="form-group">
                <label for="order">Order</label>
                <select class="form-control" id="order" name="order">
                    <option>Alphabetical</option>
                    <option>Top-K</option>
                </select>
            </div>
            <div class="form-group">
                <label for="row">Category</label>
                <select class="form-control" id="category" name="category">
                    <option value="0"> All Categories </option>
                    <%  while(categories.next()){
                            if(categories.getInt("id") == category){
                    %>
                            <option value="<%=categories.getInt("id")%>" selected><%=categories.getString("name")%></option>
                    <%
                            }
                            else{
                    %>
                            <option value="<%=categories.getInt("id")%>"><%=categories.getString("name")%></option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>
            <input class="btn btn-primary" type="submit" name="query" value="Run Query"/>
        </form>
    </div>
  </div>
  <% if ("POST".equalsIgnoreCase(request.getMethod())) { %>
  <div>
    <table class="table table-striped">
      <tr>
        <td></td>
        <% int count = 0;
        int firstId = -1;
        while(rs.next()) {
          //get first id
          if(count == 0) {
            firstId = rs.getInt("userId");
          }
          //only get 10 products or only get as many products as available if less than 10
          if(count >= 10 || rs.getInt("userId") != firstId) {
            break;
          } %>
        <td style="font-weight: bold"><%= rs.getString("prodname") %> (<%= rs.getDouble("totalProd") %>)</td>
        <% count++;
        } //end while
        rs.beforeFirst(); %>
      </tr>
      <tr>
      <%
      int currId = -1;
      int newId = -1;
      while(rs.next()) {
        newId = rs.getInt("userId");
        if(currId == -1) {
          currId = newId; %>
          <td style="font-weight: bold"><%=rs.getString("username") %> (<%=rs.getDouble("totalUser") %>)</td>
          <td><%=rs.getDouble("spent") %></td>
        <% }
        else if(currId != newId) { //new user found, end old row make new one
          currId = newId; %>
        </tr>
        <tr>
          <td style="font-weight: bold"><%=rs.getString("username") %> (<%=rs.getDouble("totalUser") %>)</td>
          <td><%=rs.getDouble("spent") %></td>
        <% } else { /* just another column */ %>
          <td><%=rs.getDouble("spent") %></td>
        <% } /* end ifelse */ %>
      <% } /* end while */ %>
      </tr>
    </table>
  </div>
  <% } /* endif */ %>
</body>
</html>