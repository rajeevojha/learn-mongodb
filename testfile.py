def predict_sales_trend():
    # This function predicts the sales trend based on historical data.
    # It uses a simple linear regression model for prediction.
    
    import pandas as pd
    from sklearn.linear_model import LinearRegression
    import numpy as np
    
    # Load historical sales data
    data = pd.read_csv('sales_data.csv')
    
    # Prepare the data for training
    X = np.array(data['Month']).reshape(-1, 1)
    y = np.array(data['Sales'])
    
    # Create and train the model
    model = LinearRegression()
    model.fit(X, y)
    
    # Predict future sales
    future_months = np.array(range(len(data), len(data) + 12)).reshape(-1, 1)
    predictions = model.predict(future_months)
    
    return predictions

