#!/usr/bin/env python3
from prefect import task, flow
import pandas as pd
import numpy as np
from pathlib import Path
import os


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


@flow(name="Titanic data pipeline")
def titanic_pipeline(
    input_path: str = "titanic.csv",
    output_path: str = "./data/processed/titanic_processed.csv",
) -> pd.DataFrame:
    """Main pipeline flow"""
    # Load the data
    raw_data = load_data(input_path)

    # Clean the data
    cleaned_data = clean_data(raw_data)

    # Engineer features
    processed_data = engineer_features(cleaned_data)

    # Save the processed data
    save_processed_data(processed_data, output_path)

    return processed_data


if __name__ == "__main__":
    titanic_pipeline(input_path="data/raw/titanic.csv")
