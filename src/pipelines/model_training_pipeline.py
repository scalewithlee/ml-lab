#!/usr/bin/env python3
"""
Titanic Pipeline: A Complete ML Workflow

This pipeline demonstrates a supervised machine learning workflow using the Titanic dataset.
It implements a "hold-out validation" approach, where:

1. Data Processing: We clean, engineer features, and prepare the raw data
   - Converting categorical features (like 'Sex' and 'Embarked') into numeric values using one-hot encoding
   - Creating new features like FamilySize and IsAlone to capture important relationships

2. Train-Test Split: We divide our dataset into two parts
   - Training set (default 70%): Used to teach the model the patterns between features and survival outcomes
   - Test set (default 30%): Held back to evaluate how well the model performs on unseen data

3. Model Training: We use the training data to build a machine learning model
   - Features (X): Passenger attributes like age, class, sex (independent variables)
   - Target (y): The survival outcome we're trying to predict (dependent variable)

4. Model Evaluation: We test the model's ability to generalize to new data
   - The model only sees the features (X_test) from the test set
   - We compare the model's predictions to the actual historical survival outcomes (y_test)
   - This simulates how the model would perform on new passengers with unknown survival outcomes

Key insight: While we already know who survived in our historical dataset, the goal is to build
a model that can predict survival for new passengers where the outcome is unknown. This is why
we hold back part of our data during training - to fairly test if our model has learned
generalizable patterns rather than just memorizing examples.

The pipeline uses Prefect for workflow orchestration, making each step reusable, observable,
and maintainable.
"""
from prefect import task, flow
import pandas as pd
from pathlib import Path
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from joblib import dump


@task(name="Load Titanic data", log_prints=True)
def load_data(file_path: str) -> pd.DataFrame:
    """Load the Titanic dataset"""
    df = pd.read_csv(file_path)
    print(f"Loaded data with {df.shape[0]} rows and {df.shape[1]} columns")
    return df


@task(name="Clean data")
def clean_data(df: pd.DataFrame) -> pd.DataFrame:
    """Handle missing values and drop unneccesary columns"""
    # Drop less useful columns
    df = df.drop(["PassengerId", "Name", "Ticket", "Cabin"], axis=1)

    # Fill missing values
    df["Age"] = df["Age"].fillna(df["Age"].median())
    df["Embarked"] = df["Embarked"].fillna(df["Embarked"].mode()[0])
    df["Fare"] = df["Fare"].fillna(df["Fare"].median())

    print("Data cleaning complete")
    return df


@task(name="Engineer features")
def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    """Create new features"""
    # Create family size feature
    df["FamilySize"] = df["SibSp"] + df["Parch"] + 1

    # Create is_alone feature
    df["IsAlone"] = (df["FamilySize"] == 1).astype(int)

    # Convert categorical features (strings) into ML-friendly values
    df = pd.get_dummies(df, columns=["Sex", "Embarked"], drop_first=True)

    print("Feature engineering completed")
    return df


@task(name="Save processed data")
def save_processed_data(df: pd.DataFrame, output_path: str) -> None:
    """Save the processed data"""
    output_dir = Path(output_path).parent
    output_dir.mkdir(exist_ok=True, parents=True)

    df.to_csv(output_path, index=False)
    print(f"Processed data saved to {output_path}")


@task(name="Split data")
def split_data(df: pd.DataFrame, target_column: str = "Pclass", test_size: float = 0.3):
    """
    Split data into training and testing sets.

    Args:
        target_column: the column we are trying to predict. using historical data, we will train a model to predict the values in target_column on new data where we don't know the outcome.
        test_size: the portion of data used for testing (as opposed to training)
    """
    # Separate features (X) from target (y)
    X = df.drop(target_column, axis=1)
    y = df[target_column]

    # Split into train and test sets
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=42
    )

    print(
        f"Data split: {X_train.shape[0]} training samples, {X_test.shape[0]} testing samples"
    )
    return X_train, X_test, y_train, y_test


@task(name="Train model")
def train_model(X_train, y_train):
    """
    Train a model with processed data

    Args:
        X_train: Training features
        y_train: Training target values
    """
    # Create a RandomForest classifier (good baseline model)
    # "Forest" refers to a bunch of trees... decision trees, that is.
    model = RandomForestClassifier(n_estimators=100, random_state=42)

    # Train the model
    model.fit(X_train, y_train)

    print("Model training complete")
    return model


@task(name="Evaluate model")
def evaluate_model(model, X_test, y_test):
    """
    Evaluate model performance

    Args:
        model: trained model
        X_test: testing features
        y_test: true target values for testing
    """
    # Make predictions on test data
    y_pred = model.predict(X_test)

    # Calculate accuracy
    accuracy = accuracy_score(y_test, y_pred)

    # Generate detailed classification report
    report = classification_report(y_test, y_pred)

    print(f"Model accuracy: {accuracy:.4f}\n")
    print("Classification report:")
    print(report)

    # Print feature importances
    print("Feature importance:")
    feature_importance = pd.DataFrame(
        {"Feature": X_test.columns, "Importance": model.feature_importances_}
    ).sort_values("Importance", ascending=False)
    print(feature_importance)

    # Show some example predictions
    print("Sample predictions:")
    results_df = pd.DataFrame({"Actual": y_test.values, "Predicted": y_pred})
    print(results_df.head(10))

    return {"accuracy": accuracy, "report": report}


@task(name="Save model")
def save_model(model, path: str):
    """
    Save the trained model

    Args:
        model: Trained model to save
        path: Path where model will be saved
    """
    # Create directory if it doesn't exist
    output_dir = Path(path).parent
    output_dir.mkdir(exist_ok=True, parents=True)

    # Save model using joblib
    dump(model, path)
    print(f"Model saved to {path}")


@flow(name="Titanic data pipeline")
def titanic_pipeline(
    input_path: str = "titanic.csv",
    processed_path: str = "./data/processed/titanic_processed.csv",
    model_path: str = "./models/titanic_model.joblib",
):
    """Complete Titanic ML pipeline: data processing and model training"""

    # Process data
    raw_data = load_data(input_path)
    cleaned_data = clean_data(raw_data)
    processed_data = engineer_features(cleaned_data)
    save_processed_data(processed_data, processed_path)

    # Model training
    X_train, X_test, y_train, y_test = split_data(processed_data)
    model = train_model(X_train, y_train)
    metrics = evaluate_model(model, X_test, y_test)
    save_model(model, model_path)

    return metrics


if __name__ == "__main__":
    titanic_pipeline(input_path="data/raw/titanic.csv")
