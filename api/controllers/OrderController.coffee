OrderController =
  # order building section
 create : (req, res)  ->
    # 1. 透過 Productid 找到 model product --- ok
    # 2. 檢查 user 是否存在，若否進行建立  ---
    # 3. 建立訂單 order                    ---
    # order = {
    #   id: '11223344'
    #   quantity: 10
    #
    #   user: {
    #     username: 'test'
    #     email: 'test@gmail.com'
    #     mobile: '0911-111-111'
    #     address: '台灣省台灣市台灣路'
    #   }
    #
    #   product: {
    #     name: '柚子'
    #     desctipt: '又大又好吃'
    #     stockQuantity: 10
    #     price: 100
    #     id: 1
    #   }
    # }
    ##############################################
    # debug switch
    debug = true

    # get params
    # quantity = req.param("quantity")
    # jProduct = req.param('product')
    # jUser = req.param('user')

    newPurchase = req.body
    quantity = newPurchase.quantity
    jProduct = newPurchase.product
    jUser = newPurchase.user


    # console outputs
    if debug
      console.log ' ===================>'
      console.log 'product',jProduct
      console.log 'user',jUser
      console.log ' ===================>'

    # step 1 : get product by given id.
    doFindProduct = (done) ->
      db.Product.findById(1).then (findProduct) ->
        #
        if debug
          console.log ' ===================>'
          console.log findProduct.dataValues
          console.log ' ===================>'

        #
        return done(msg: '找不到商品！ 請確認商品ID！') if !findProduct
        return done(msg: '商品缺貨！') if findProduct.stockQuantity < 1
        done(null)

    # step 2 : check user whether exists.
    doFindOrCreateUser = (done) ->
      #db.User.findOrCreate({where: {email:jUser.email}, defaults:jUser}).then (thisUser) ->
      db.User.findOne({where: {email:jUser.email}}).then (thisUser) ->
        # if user not exists
        if !thisUser
          console.log 'user not exists. create one ...'
          # create a new user
          db.User.create(jUser).then (createdUser) ->
            if createdUser
              doCreateOrder(createdUser.id)
              console.log '======================>\n
              new user created. ===>\n',createdUser.get()
              done(null)
        # user exists.
        else
          console.log 'find a exist user. id===>',thisUser.id
          done(null)

    # step 3 : insert a new order
    doCreateOrder = (userid,done) ->
      # build a order
      theDate = new Date
      newOrder = {
        quantity: quantity
        UserId : userid
        orderId: jProduct.id + jProduct.name + theDate.getTime()
      }
      # insert the order
      db.Order.create(newOrder).then (createdOrder) ->
        if createdOrder
          console.log '======================>\n
          new order includes ==>\n',createdOrder.get()
          res.ok {
            order: createdOrder
            success: true
          }
        else
          res.ok {
            order: null
            success: !true
          }

    # do works async just in case.
    async.series [
      doFindProduct
      doFindOrCreateUser
      #doCreateOrder
    ], (err, results) ->
      return

  # order status section
  status:  (req, res) ->

    order = {
      id: '11223344'
      quantity: 10

      user: {
        username: 'test'
        email: 'test@gmail.com'
        mobile: '0911-111-111'
        address: '台灣省台灣市台灣路'
      }

      product: {
        name: '柚子'
        desctipt: '又大又好吃'
        stockQuantity: 10
        price: 100
        id: 1
      }
    }

    res.ok {
      order: order
    }

module.exports = OrderController
