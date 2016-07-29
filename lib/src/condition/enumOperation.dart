part of proto_game.operation;

class Operation {
  static Operation EQUALS_TO             = new Operation._(false, true, false),
                   ASSIGN                = new Operation._(true, false, false),
                   MINUS                 = new Operation._(false, false, true),
                   PLUS                  = new Operation._(false, false, true),
                   DIVIDE                = new Operation._(false, false, true),
                   MULTIPLY              = new Operation._(false, false, true),
                   MODULO                = new Operation._(false, false, true),
                   SUPERIOR              = new Operation._(false, true, false),
                   INFERIOR              = new Operation._(false, true, false),
                   SUPERIOR_EQUALS       = new Operation._(false, true, false),
                   INFERIOR_EQUALS       = new Operation._(false, true, false),
                   PLUS_ASSIGN           = new Operation._(true, false, false),
                   MINUS_ASSIGN          = new Operation._(true, false, false),
                   DIVIDE_ASSIGN         = new Operation._(true, false, false),
                   MULTIPLY_ASSIGN       = new Operation._(true, false, false),
                   MODULO_ASSIGN         = new Operation._(true, false, false),
                   CONDITIONAL           = new Operation._(false, false, false),
                   CONDITIONAL_SEPARATOR = new Operation._(false, false, false);

  bool _isAssign;
  bool _isCondition;
  bool _isOperand;

  Operation._(this._isAssign, this._isCondition, this._isOperand);

  bool get isAssign => _isAssign;
  bool get isCondition => _isCondition;
  bool get isOperand => _isOperand;
}

