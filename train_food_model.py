"""
EatWise Food Classification Model Training Script
Train a custom model for 47 Indonesian foods

Requirements:
pip install tensorflow keras pillow numpy matplotlib scikit-learn
"""

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

# ============================================
# CONFIGURATION
# ============================================
CONFIG = {
    'dataset_path': 'food_dataset',  # Path to your dataset
    'img_size': (224, 224),
    'batch_size': 32,
    'epochs': 50,
    'learning_rate': 0.001,
    'num_classes': 47,  # Number of food categories
    'model_name': 'eatwise_food_model',
}

# ============================================
# DATA PREPARATION
# ============================================
def prepare_data():
    """Prepare training and validation data with augmentation"""
    
    # Data augmentation for training
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=20,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='nearest'
    )
    
    # Only rescaling for validation
    val_datagen = ImageDataGenerator(rescale=1./255)
    
    # Load training data
    train_generator = train_datagen.flow_from_directory(
        f"{CONFIG['dataset_path']}/train",
        target_size=CONFIG['img_size'],
        batch_size=CONFIG['batch_size'],
        class_mode='categorical'
    )
    
    # Load validation data
    val_generator = val_datagen.flow_from_directory(
        f"{CONFIG['dataset_path']}/validation",
        target_size=CONFIG['img_size'],
        batch_size=CONFIG['batch_size'],
        class_mode='categorical'
    )
    
    return train_generator, val_generator

# ============================================
# MODEL ARCHITECTURE
# ============================================
def create_model():
    """Create MobileNetV2-based model for food classification"""
    
    # Load pre-trained MobileNetV2 (without top layers)
    base_model = keras.applications.MobileNetV2(
        input_shape=(*CONFIG['img_size'], 3),
        include_top=False,
        weights='imagenet'
    )
    
    # Freeze base model layers
    base_model.trainable = False
    
    # Build model
    model = keras.Sequential([
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.Dropout(0.2),
        layers.Dense(512, activation='relu'),
        layers.Dropout(0.3),
        layers.Dense(CONFIG['num_classes'], activation='softmax')
    ])
    
    return model

# ============================================
# TRAINING
# ============================================
def train_model(model, train_gen, val_gen):
    """Train the model"""
    
    # Compile model
    model.compile(
        optimizer=keras.optimizers.Adam(CONFIG['learning_rate']),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    # Callbacks
    callbacks = [
        keras.callbacks.ModelCheckpoint(
            'best_model.h5',
            save_best_only=True,
            monitor='val_accuracy'
        ),
        keras.callbacks.EarlyStopping(
            patience=10,
            restore_best_weights=True
        ),
        keras.callbacks.ReduceLROnPlateau(
            factor=0.5,
            patience=5
        )
    ]
    
    # Train
    history = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=CONFIG['epochs'],
        callbacks=callbacks
    )
    
    return history

# ============================================
# CONVERT TO TFLITE
# ============================================
def convert_to_tflite(model):
    """Convert Keras model to TensorFlow Lite"""
    
    # Convert to TFLite with float16 quantization
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]
    
    tflite_model = converter.convert()
    
    # Save
    with open('eatwise_float16.tflite', 'wb') as f:
        f.write(tflite_model)
    
    print("✅ Model converted to TFLite: eatwise_float16.tflite")

# ============================================
# MAIN
# ============================================
if __name__ == '__main__':
    print("🚀 Starting EatWise Model Training...")
    
    # 1. Prepare data
    print("\n📊 Preparing data...")
    train_gen, val_gen = prepare_data()
    
    # 2. Create model
    print("\n🏗️ Creating model...")
    model = create_model()
    model.summary()
    
    # 3. Train model
    print("\n🎓 Training model...")
    history = train_model(model, train_gen, val_gen)
    
    # 4. Convert to TFLite
    print("\n📦 Converting to TFLite...")
    convert_to_tflite(model)
    
    # 5. Save labels
    print("\n📝 Saving labels...")
    labels = sorted(train_gen.class_indices.keys())
    with open('labels.txt', 'w') as f:
        for label in labels:
            f.write(f"{label}\n")
    
    print("\n✅ Training complete!")
    print(f"📁 Files created:")
    print(f"   - eatwise_float16.tflite (model)")
    print(f"   - labels.txt (class labels)")
    print(f"   - best_model.h5 (Keras model)")
