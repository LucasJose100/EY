import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _edittedProduct = Product(
      id: '',
      title: '',
      description: 'description',
      imageUrl: 'imageUrl',
      price: 0);
  var _initValues = {
    'id': '',
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  /*@override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }
*/
  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    if (_edittedProduct.id != '') {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_edittedProduct.id, _edittedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_edittedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('An error occured'),
            content: Text('Something went wrong!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String;

      if (productId != '') {
        _edittedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
      }

      if (productId != '') {
        _initValues = {
          'id': _edittedProduct.id,
          'title': _edittedProduct.title,
          'description': _edittedProduct.description,
          'price': _edittedProduct.price.toString(),
          'imageUrl': _edittedProduct.imageUrl,
        };
        _imageUrlController.text = _edittedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: () {
              _saveForm();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a value.';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onSaved: (value) {
                          _edittedProduct = Product(
                            id: _edittedProduct.id,
                            title: value!,
                            description: _edittedProduct.description,
                            imageUrl: _edittedProduct.imageUrl,
                            price: _edittedProduct.price,
                            isFavorite: _edittedProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a title for the product.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number.';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than zero.';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          _edittedProduct = Product(
                            id: _edittedProduct.id,
                            title: _edittedProduct.title,
                            description: _edittedProduct.description,
                            imageUrl: _edittedProduct.imageUrl,
                            price: double.parse(value!),
                            isFavorite: _edittedProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a description.';
                          }
                          if (value.length < 10) {
                            return 'Description need at least 15 characters.';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        onSaved: (value) {
                          _edittedProduct = Product(
                            id: _edittedProduct.id,
                            title: _edittedProduct.title,
                            description: value!,
                            imageUrl: _edittedProduct.imageUrl,
                            price: _edittedProduct.price,
                            isFavorite: _edittedProduct.isFavorite,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Center(child: Text('Enter a URL'))
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: _initValues['imageUrl'],
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter an image URL.';
                                }

                                /*if (!value.endsWith('.png') &&
                              !value.endsWith('.jpg') &&
                              !value.endsWith('.jpeg')) {
                            return 'Please enter a valid image URL.';
                          }
*/
                                return null;
                              },
                              keyboardType: TextInputType.url,
                              //controller: _imageUrlController,
                              onEditingComplete: () {
                                setState(() {});
                              },
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onSaved: (value) {
                                _edittedProduct = Product(
                                  id: _edittedProduct.id,
                                  title: _edittedProduct.title,
                                  description: _edittedProduct.description,
                                  imageUrl: value!,
                                  price: _edittedProduct.price,
                                  isFavorite: _edittedProduct.isFavorite,
                                );
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
