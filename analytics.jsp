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

        int category = 0; 	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		//String action = request.getParameter("submit");

            // row option for query     
            String rowOption = request.getParameter("row"); 

            // order option for query 
            String orderOption = request.getParameter("order");

            // category id for query, if all categories then it equals 0 
            category = Integer.parseInt(request.getParameter("category")); 
            


	}
	
	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery("SELECT p.id, p.name, p.sku, p.price, c.name as category_name" + 
		" FROM products p, categories c where is_delete = false and c.id = p.category_id");
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
                    <% 
                        while(categories.next()){
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
</body>
</html>
