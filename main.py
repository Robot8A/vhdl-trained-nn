import sys
import keras
import numpy
import matplotlib.pyplot as plt

import vhdl

__author__ = "Héctor Ochoa Ortiz"


def usageFail(src, txt=None):
    if txt is not None:
        print("ERROR: " + txt, file=sys.stderr)
    print("Usage: ", src, "<trainingFile> <inputNumber> <neuronNumberForEachLayer> <trainingEpochs> <batchSize>", file=sys.stderr)
    print("        The training file should be a csv file, with ',' separators.", file=sys.stderr)
    print("        The inputNumber-th first columns of the file will be the input training dataset, from the inputNumber-th column to the final column of the file will be the output training dataset.", file=sys.stderr)
    print("        The neuron numbers for each layer should be separated by a ','.", file=sys.stderr)
    print("Example: ", src, "training_datasets/pima-indians-diabetes.csv 8 3,5,1 100 10", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    args = sys.argv
    if len(args) != 6:
        usageFail(args[0], "Wrong number of parameters")

    neurons = args[3].split(",")
    # ensure parameters are correct
    try:
        inputNumber = int(args[2])
        if not inputNumber > 0:
            usageFail(args[0], "Input number must be more than 0")
        for i in range(len(neurons)):
            neurons[i] = int(neurons[i])
            if not neurons[i] > 0:
                usageFail(args[0], "Every layer must have more than 0 neurons")
        epochs = int(args[4])
        if not epochs > 0:
            usageFail(args[0], "Epochs must be more than 0")
        batch_size = int(args[5])
        if not batch_size > 0:
            usageFail(args[0], "Batch size must be more than 0")
    except Exception as e:
        usageFail(args[0], str(e))

    # load the dataset
    dataset = numpy.loadtxt(args[1], delimiter=',')
    # split into input (X) and output (y) variables
    X = dataset[:, 0:inputNumber]
    y = dataset[:, inputNumber:]

    if y.shape[1] != neurons[len(neurons)-1]:
        usageFail(args[0], "Csv output columns does not correspond to output layer neuron number")

    # create the network model
    model = keras.models.Sequential()

    # add layers
    model.add(keras.layers.Dense(units=neurons[0], input_dim=inputNumber, activation="hard_sigmoid"))
    for i in neurons[1:]:
        model.add(keras.layers.Dense(units=i, activation="hard_sigmoid"))

    # configure learning process
    model.compile(loss='binary_crossentropy', optimizer=keras.optimizers.SGD(), metrics=["accuracy"])
    model.summary()

    # fit the keras model on the dataset
    history = model.fit(X, y, epochs=epochs, batch_size=batch_size, verbose=1)

    # evaluate the keras model
    _, accuracy = model.evaluate(X, y)
    print('Accuracy: %.2f' % (accuracy * 100))

    # Get weights and biases
    counter = 0
    a = {}
    for l in model.layers:
        a.update({counter: {"w": l.get_weights()[0], "b": l.get_weights()[1]}})
        counter += 1

    print("\n")
    print("--WEIGHTS--")
    print(a)
    print("\n")

    keras.utils.plot_model(model, to_file='model.png', show_shapes=True, show_layer_names=False)

    # Plot accuracy and loss values
    plt.figure()
    plt.subplot(211)
    plt.plot(history.history['accuracy'], color='blue')
    plt.title('Model accuracy and loss')
    plt.ylabel('Accuracy')
    plt.subplot(212)
    plt.plot(history.history['loss'], color='darkred')
    plt.ylabel('Loss')
    plt.xlabel('Epoch')
    #plt.legend(['Train', 'Test'], loc='upper left')
    plt.savefig('acc_loss.png')
    #plt.show()

    vhdl.create(
        input_dim=inputNumber,
        neurons=neurons,
        weights=a
    )

    pass
