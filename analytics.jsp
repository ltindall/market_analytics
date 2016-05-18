<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<title>CSE135 Project</title>
<link href="css/style.css" rel="stylesheet">
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
	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("submit");
		if (action.equals("delete")) {
			int id = Integer.parseInt(request.getParameter("id"));
			Statement stmt = conn.createStatement();
			String sql = "UPDATE products SET is_delete = true where id = " + id;
			try {
				stmt.executeUpdate(sql);
			}
			catch(Exception e) {out.println("<script>alert('can not delete!');</script>");}
		}
		else if (action.equals("update")) {
			int id = Integer.parseInt(request.getParameter("id"));
			String name = request.getParameter("name");
			String sku = request.getParameter("sku");
			float price = Float.parseFloat(request.getParameter("price"));
			Statement stmt = conn.createStatement();
			String sql = "UPDATE products SET name = '" + name +
					"', sku = '" + sku + "', price = " + price + " where id = " + id;
			int result = stmt.executeUpdate(sql);
			if (result == 1) out.println("<script>alert('update product sucess!');</script>");
		    else out.println("<script>alert('update product fail!');</script>");
		}
		else if (action.equals("insert")) {
			String name = request.getParameter("name");
			String category_name = request.getParameter("category_name");
			String sku = request.getParameter("sku");
			float price = Float.parseFloat(request.getParameter("price"));
			Statement stmt1 = conn.createStatement();
			ResultSet rs1 = stmt1.executeQuery("SELECT id from categories where name = '" + category_name + "'");
			if (rs1.next()) {
				int category_id = rs1.getInt(1);
				Statement stmt2 = conn.createStatement();
				String sql = "INSERT into products(name, category_id, sku, price, is_delete) values('" + name +
						"', '" + category_id + "', '" + sku + "', '" + price + "', false)";
				int result = stmt2.executeUpdate(sql);
				if (result == 1) out.println("<script>alert('insert into product sucess!');</script>");
			    else out.println("<script>alert('insert into product fail!');</script>");
			}
			else {out.println("<script>alert('category does not exist!');</script>");}
		}
	}
	
	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery("SELECT p.id, p.name, p.sku, p.price, c.name as category_name" + 
		" FROM products p, categories c where is_delete = false and c.id = p.category_id");
        Statement catStmt = conn.createStatement(); 
        ResultSet categories = catStmt.executeQuery("SELECT c.name FROM categories c");  
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
                <label for="row">Order</label>
                <select class="form-control" id="order" name="order"> 
                    <option>Alphabetical</option>
                    <option>Top-K</option>
                </select>
            </div>
            <div class="form-group">
                <label for="row">Category</label>
                <select class="form-control" id="category" name="category"> 
                    <% 
                        while(categories.next()){
                    %>
                        <option><%=categories.getString("name")%></option>
                    <%
                        }
                    %>
                </select>
            </div>
            <input class="btn btn-primary" type="submit" name="query" value="Run Query"/>
        </form>
    </div>
</div>
</body>
</html>
